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
from acme.operators.file_operators import FileToPredictableLocationOperator
from acme.operators.file_operators import PredictableLocationToFinalLocationOperator


seven_days_ago = datetime.combine(
    datetime.today() - timedelta(7),
    datetime.min.time())

args = {
    'owner': 'airflow',
    'start_date': seven_days_ago,
    'provide_context': True
}

dag = airflow.DAG(
    'file_ingest',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    default_args=args,
    max_active_runs=1)

pick_up_file = FileToPredictableLocationOperator(
    task_id='pick_up_file',
    src_conn_id='fs_source_system',
    dst_conn_id='fs_archive',
    file_mask="some_file_pattern_{{ ds_nodash }}",
    dag=dag)

load_file = PredictableLocationToFinalLocationOperator(
    task_id='load_file',
    src_conn_id='fs_archive',
    dst_conn_id='fs_target',
    src_task_id='pick_up_file',
    dag=dag)

pick_up_file >> load_file


if __name__ == "__main__":
    dag.cli()
