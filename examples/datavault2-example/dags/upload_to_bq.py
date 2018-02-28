# -*- coding: utf-8 -*-
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import print_function
import airflow
from datetime import datetime, timedelta
from airflow.operators.hive_operator import HiveOperator
from airflow.operators.dummy_operator import DummyOperator
from acme.operators.hive_to_gcs_operator import HiveToGcsOperator
from airflow.contrib.operators.gcs_to_bq import GoogleCloudStorageToBigQueryOperator
from airflow.models import Variable


args = {
    'owner': 'airflow',
    'start_date': airflow.utils.dates.days_ago(1),
    'provide_context': True,
    'depends_on_past': True
}

dag = airflow.DAG(
    'upload_to_bq',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    template_searchpath='/usr/local/airflow/sql',
    default_args=args,
    max_active_runs=1)


all_done =  DummyOperator(
    task_id='all_done',
    dag=dag)

t1 = HiveToGcsOperator(
    hql='bigquery/upload_flat_table.hql',
    bucket='datavault2-example',
    subdir='{{ds_nodash[:4]}}/{{ds_nodash[4:6]}}/{{ds_nodash[6:8]}}',
    file_pattern='dv_star_data-{0}.json',
    schema='dv_star',
    hiveserver2_conn_id='hiveserver2-dvstar',
    google_cloud_storage_conn_id='gcp',
    task_id='upload_flat_table',
    dag=dag)

t2 = GoogleCloudStorageToBigQueryOperator(
    bucket='datavault2-example',
    source_objects=['{{ds_nodash[:4]}}/{{ds_nodash[4:6]}}/{{ds_nodash[6:8]}}/dv_star_data-*.json'],
    destination_project_dataset_table='information_mart.flat_table',
    source_format='NEWLINE_DELIMITED_JSON',
    write_disposition='WRITE_TRUNCATE',
    src_fmt_configs={'autodetect': True},
    bigquery_conn_id='gcp',
    google_cloud_storage_conn_id='gcp',
    task_id='gcs_to_bq',
    dag=dag)

t1 >> t2
t2 >> all_done


if __name__ == "__main__":
    dag.cli()
