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
from datetime import datetime, timedelta
import os

import airflow
from airflow.operators.bash_operator import BashOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.models import Variable

from acme.operators.pg_to_file_operator import StagePostgresToFileOperator
from acme.operators.file_to_hive_operator import StageFileToHiveOperator

args = {
    'owner': 'airflow',
    'start_date': datetime(2005, 5, 24),
    'end_date': datetime(2005, 8, 24),
    'provide_context': True,
    # We want to maintain chronological order when loading the datavault
    'depends_on_past': True
}

dag = airflow.DAG(
    'dvdrentals_full_rebuild',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=120),
    template_searchpath='/usr/local/airflow/sql',
    default_args=args,
    max_active_runs=1)


loading_done = DummyOperator(
    task_id='loading_done',
    dag=dag)


full_rebuild_from_psa = BashOperator(
    bash_command='/usr/local/airflow/dataflow/start_full_dv_rebuild.sh {{ts}}',
    task_id='full_rebuild_from_psa',
    dag=dag)


def create_loading_operator(hive_table, partition=None):
    field_dict = schema.schemas[hive_table]
    _, table = hive_table.split('.')

    t1 = StageFileToHiveOperator(
        hive_table=table,
        relative_file_path='full-load/dvdrentals/' + hive_table + '/{{ds[:4]}}/{{ds[5:7]}}/{{ds[8:10]}}/',
        field_dict=field_dict,
        create=True,
        recreate=True,
        file_conn_id='filestore',
        hive_cli_conn_id='hive_dvdrentals_staging',
        task_id='load_{0}'.format(hive_table),
        dag=dag)

    full_rebuild_from_psa >> t1 >> loading_done
    return t1

"""
create_loading_operator('public.address')
create_loading_operator('public.actor')
create_loading_operator('public.category')
create_loading_operator('public.city')
create_loading_operator('public.country')
create_loading_operator('public.customer')
create_loading_operator('public.film')
create_loading_operator('public.film_actor')
create_loading_operator('public.film_category')
create_loading_operator('public.inventory')
create_loading_operator('public.language')
create_loading_operator('public.payment', partition='payment_date')
create_loading_operator('public.rental', partition='rental_date')
create_loading_operator('public.staff')
create_loading_operator('public.store')
"""

if __name__ == "__main__":
    dag.cli()
