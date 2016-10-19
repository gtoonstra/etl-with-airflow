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
from acme.operators.postgres_to_postgres import PostgresToPostgresOperator


seven_days_ago = datetime.combine(
    datetime.today() - timedelta(7),
    datetime.min.time())
    
args = {
    'owner': 'airflow',
    'start_date': seven_days_ago,
    'provide_context': True,
    'depends_on_past': True
}

dag = airflow.DAG(
    'full_example',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    template_searchpath='/home/gt/airflow/sql',
    default_args=args,
    max_active_runs=1)

oper_1 = PostgresToPostgresOperator(
    sql='copy_order_info.sql',
    pg_table='staging.order_info',
    src_postgres_conn_id='postgres_oltp',
    dest_postgress_conn_id='postgres_dwh',
    #pg_preoperator='TRUNCATE staging.order_info',
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}"},
    task_id='ingest_order',
    dag=dag)

oper_2 = PostgresToPostgresOperator(
    sql='copy_orderline.sql',
    pg_table='staging.orderline',
    src_postgres_conn_id='postgres_oltp',
    dest_postgress_conn_id='postgres_dwh',
    #pg_preoperator='TRUNCATE staging.orderline',
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}"},
    task_id='ingest_orderline',
    dag=dag)

oper_1 >> oper_2


if __name__ == "__main__":
    dag.cli()
