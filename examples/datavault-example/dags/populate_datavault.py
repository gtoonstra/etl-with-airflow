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
from acme.operators.datavault_operators import PostgresToPostgresOperator
from acme.operators.datavault_operators import PostgresOperatorWithTemplatedParams
from acme.operators.datavault_operators import AuditOperator
from airflow.models import Variable
import logging


args = {
    'owner': 'airflow',
    'depends_on_past': True,
    'start_date': airflow.utils.dates.days_ago(7),
    'provide_context': True,
    'max_active_runs': 1
}

tmpl_search_path = Variable.get("sql_path")

dag = airflow.DAG(
    'populate_datavault',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    template_searchpath=tmpl_search_path,
    default_args=args,
    max_active_runs=1)

audit_id = AuditOperator(
    task_id='audit_id',
    postgres_conn_id='datavault',
    audit_key="dv_staging",
    cycle_dtm="{{ ts }}",
    dag=dag)

extract_customers = PostgresToPostgresOperator(
    sql='staging/stage_customer.sql',
    pg_table='staging.customer',
    src_postgres_conn_id='oltp',
    dest_postgress_conn_id='datavault',
    pg_preoperator="TRUNCATE staging.customer",
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='get_audit_id', key='audit_id') }}"},
    task_id='extract_customers',
    dag=dag)

extract_order_info = PostgresToPostgresOperator(
    sql='staging/stage_order_info.sql',
    pg_table='staging.order_info',
    src_postgres_conn_id='oltp',
    dest_postgress_conn_id='datavault',
    pg_preoperator="TRUNCATE staging.order_info",
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='get_audit_id', key='audit_id') }}"},
    task_id='extract_order_info',
    dag=dag)

extract_orderline = PostgresToPostgresOperator(
    sql='staging/stage_orderline.sql',
    pg_table='staging.orderline',
    src_postgres_conn_id='oltp',
    dest_postgress_conn_id='datavault',
    pg_preoperator="TRUNCATE staging.orderline",
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='get_audit_id', key='audit_id') }}"},
    task_id='extract_orderline',
    dag=dag)

extract_product = PostgresToPostgresOperator(
    sql='staging/stage_product.sql',
    pg_table='staging.product',
    src_postgres_conn_id='oltp',
    dest_postgress_conn_id='datavault',
    pg_preoperator="TRUNCATE staging.product",
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='get_audit_id', key='audit_id') }}"},
    task_id='extract_product',
    dag=dag)

hub_customer = PostgresOperatorWithTemplatedParams(
    sql='datavault/hub_customer.sql',
    postgres_conn_id='datavault',
    parameters={"load_dts": "{{ ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='audit_id', key='audit_id') }}",
                "r_src": "oltp"},
    task_id='hub_customer',
    dag=dag)

hub_order = PostgresOperatorWithTemplatedParams(
    sql='datavault/hub_order.sql',
    postgres_conn_id='datavault',
    parameters={"load_dts": "{{ ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='audit_id', key='audit_id') }}",
                "r_src": "oltp"},
    task_id='hub_order',
    dag=dag)

hub_product = PostgresOperatorWithTemplatedParams(
    sql='datavault/hub_product.sql',
    postgres_conn_id='datavault',
    parameters={"load_dts": "{{ ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='audit_id', key='audit_id') }}",
                "r_src": "oltp"},
    task_id='hub_product',
    dag=dag)

link_order = PostgresOperatorWithTemplatedParams(
    sql='datavault/link_order.sql',
    postgres_conn_id='datavault',
    parameters={"load_dts": "{{ ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='audit_id', key='audit_id') }}",
                "r_src": "oltp"},
    task_id='link_order',
    dag=dag)

link_orderline = PostgresOperatorWithTemplatedParams(
    sql='datavault/link_orderline.sql',
    postgres_conn_id='datavault',
    parameters={"load_dts": "{{ ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='audit_id', key='audit_id') }}",
                "r_src": "oltp"},
    task_id='link_orderline',
    dag=dag)

sat_customer = PostgresOperatorWithTemplatedParams(
    sql='datavault/sat_customer.sql',
    postgres_conn_id='datavault',
    parameters={"load_dts": "{{ ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='audit_id', key='audit_id') }}",
                "r_src": "oltp"},
    task_id='sat_customer',
    dag=dag)

sat_order = PostgresOperatorWithTemplatedParams(
    sql='datavault/sat_order.sql',
    postgres_conn_id='datavault',
    parameters={"load_dts": "{{ ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='audit_id', key='audit_id') }}",
                "r_src": "oltp"},
    task_id='sat_order',
    dag=dag)

sat_product = PostgresOperatorWithTemplatedParams(
    sql='datavault/sat_product.sql',
    postgres_conn_id='datavault',
    parameters={"load_dts": "{{ ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='audit_id', key='audit_id') }}",
                "r_src": "oltp"},
    task_id='sat_product',
    dag=dag)

sat_orderline = PostgresOperatorWithTemplatedParams(
    sql='datavault/sat_orderline.sql',
    postgres_conn_id='datavault',
    parameters={"load_dts": "{{ ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='audit_id', key='audit_id') }}",
                "r_src": "oltp"},
    task_id='sat_orderline',
    dag=dag)

audit_id >> extract_customers
audit_id >> extract_order_info
audit_id >> extract_product
audit_id >> extract_orderline
extract_customers >> hub_customer
extract_order_info >> hub_order
extract_product >> hub_product
hub_order >> link_order
hub_customer >> link_order
link_order >> link_orderline
link_orderline >> sat_orderline
hub_product >> sat_product
hub_order >> sat_order
hub_customer >> sat_customer


if __name__ == "__main__":
    dag.cli()
