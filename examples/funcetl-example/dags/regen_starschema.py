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
from acme.operators.funcetl_operators import PostgresToPostgresOperator
from acme.operators.funcetl_operators import PostgresOperatorWithTemplatedParams
from acme.operators.funcetl_operators import AuditOperator
from airflow.operators.latest_only_operator import LatestOnlyOperator
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
    'regen_starschema',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    template_searchpath=tmpl_search_path,
    default_args=args,
    max_active_runs=1)

latest_only = LatestOnlyOperator(task_id='latest_only', dag=dag)

audit_id = AuditOperator(
    task_id='audit_id',
    postgres_conn_id='dwh',
    audit_key="starschema",
    cycle_dtm="{{ ts }}",
    dag=dag)

load_customer_dim = PostgresToPostgresOperator(
    sql='starschema/load_customer.sql',
    pg_table='dwh.dim_customer',
    src_postgres_conn_id='datavault',
    dest_postgress_conn_id='dwh',
    pg_preoperator="TRUNCATE dwh.dim_customer CASCADE",
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='get_audit_id', key='audit_id') }}"},
    task_id='load_customer_dim',
    dag=dag)

load_product_dim = PostgresToPostgresOperator(
    sql='starschema/load_product.sql',
    pg_table='dwh.dim_product',
    src_postgres_conn_id='datavault',
    dest_postgress_conn_id='dwh',
    pg_preoperator="TRUNCATE dwh.dim_product CASCADE",
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='get_audit_id', key='audit_id') }}"},
    task_id='load_product_dim',
    dag=dag)

load_fact_orderline = PostgresToPostgresOperator(
    sql='starschema/load_fact_orderline.sql',
    pg_table='dwh.dim_product',
    src_postgres_conn_id='datavault',
    dest_postgress_conn_id='dwh',
    pg_preoperator="TRUNCATE staging.order_facts",
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='get_audit_id', key='audit_id') }}"},
    task_id='load_fact_orderline',
    dag=dag)

truncate_orderline = PostgresOperatorWithTemplatedParams(
    sql='TRUNCATE dwh.fact_orderline',
    postgres_conn_id='dwh',
    parameters={},
    task_id='truncate_orderline',
    dag=dag)

process_order_fact = PostgresOperatorWithTemplatedParams(
    sql='starschema/process_order_fact.sql',
    postgres_conn_id='dwh',
    parameters={},
    task_id='process_order_fact',
    dag=dag)

latest_only >> audit_id
audit_id >> load_customer_dim
audit_id >> load_product_dim
audit_id >> load_fact_orderline
load_customer_dim >> truncate_orderline
load_product_dim >> truncate_orderline
load_fact_orderline >> truncate_orderline
truncate_orderline >> process_order_fact


if __name__ == "__main__":
    dag.cli()
