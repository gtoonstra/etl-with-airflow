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
from acme.operators.hive_operators import PostgresToHiveOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.models import Variable


args = {
    'owner': 'airflow',
    'start_date': airflow.utils.dates.days_ago(7),
    'provide_context': True
}

tmpl_search_path = Variable.get("sql_path")

dag = airflow.DAG(
    'staging_oltp',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    template_searchpath=tmpl_search_path,
    default_args=args,
    max_active_runs=1)

stage_customer = PostgresToHiveOperator(
    sql='select_customer.sql',
    hive_table='customer_staging',
    postgres_conn_id='postgres_oltp',
    hive_cli_conn_id='hive_staging',
    partition={"change_date": "{{ ds_nodash }}"},
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}"},
    task_id='stage_customer',
    dag=dag)

stage_orderinfo = PostgresToHiveOperator(
    sql='select_order_info.sql',
    hive_table='order_info_staging',
    postgres_conn_id='postgres_oltp',
    hive_cli_conn_id='hive_staging',
    partition={"change_date": "{{ ds_nodash }}"},
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}"},
    task_id='stage_orderinfo',
    dag=dag)

stage_orderline = PostgresToHiveOperator(
    sql='select_orderline.sql',
    hive_table='orderline_staging',
    postgres_conn_id='postgres_oltp',
    hive_cli_conn_id='hive_staging',
    partition={"change_date": "{{ ds_nodash }}"},
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}"},
    task_id='stage_orderline',
    dag=dag)

stage_product = PostgresToHiveOperator(
    sql='select_product.sql',
    hive_table='product_staging',
    postgres_conn_id='postgres_oltp',
    hive_cli_conn_id='hive_staging',
    partition={"change_date": "{{ ds_nodash }}"},
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}"},
    task_id='stage_product',
    dag=dag)

dummy = DummyOperator(
    task_id='dummy',
    dag=dag)

stage_customer >> dummy
stage_orderinfo >> dummy
stage_orderline >> dummy
stage_product >> dummy

if __name__ == "__main__":
    dag.cli()
