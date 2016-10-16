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
from airflow.operators.dummy_operator import DummyOperator


seven_days_ago = datetime.combine(
    datetime.today() - timedelta(7),
    datetime.min.time())
args = {
    'owner': 'airflow',
    'start_date': seven_days_ago,
    'provide_context': True
}

dag = airflow.DAG(
    'full_example',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    default_args=args)

oper_1 = DummyOperator(
    task_id='oper_1',
    dag=dag)

oper_2 = DummyOperator(
    task_id='oper_2',
    dag=dag)

oper_1 >> oper_2


if __name__ == "__main__":
    dag.cli()
