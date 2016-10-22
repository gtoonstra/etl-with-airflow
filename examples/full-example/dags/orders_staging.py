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
from acme.operators.dwh_operators import PostgresToPostgresOperator
from acme.operators.dwh_operators import AuditOperator
from airflow.models import Variable

seven_days_ago = datetime.combine(
    datetime.today() - timedelta(7),
    datetime.min.time())

args = {
    'owner': 'airflow',
    'start_date': seven_days_ago,
    'provide_context': True
}

tmpl_search_path = Variable.get("sql_path")

dag = airflow.DAG(
    'orders_staging',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    template_searchpath=tmpl_search_path,
    default_args=args,
    max_active_runs=1)

get_auditid = AuditOperator(
    task_id='get_audit_id',
    postgres_conn_id='postgres_dwh',
    audit_key="orders",
    cycle_dtm="{{ ts }}",
    dag=dag,
    pool='postgres_dwh')

extract_orderinfo = PostgresToPostgresOperator(
    sql='select_order_info.sql',
    pg_table='staging.order_info',
    src_postgres_conn_id='postgres_oltp',
    dest_postgress_conn_id='postgres_dwh',
    pg_preoperator="DELETE FROM staging.order_info WHERE "
        "partition_dtm >= DATE '{{ ds }}' AND partition_dtm < DATE '{{ tomorrow_ds }}'",
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='get_audit_id', key='audit_id') }}"},
    task_id='extract_orderinfo',
    dag=dag,
    pool='postgres_dwh')

extract_orderline = PostgresToPostgresOperator(
    sql='select_orderline.sql',
    pg_table='staging.orderline',
    src_postgres_conn_id='postgres_oltp',
    dest_postgress_conn_id='postgres_dwh',
    pg_preoperator="DELETE FROM staging.orderline WHERE "
        "partition_dtm >= DATE '{{ ds }}' AND partition_dtm < DATE '{{ tomorrow_ds }}'",
    parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}",
                "audit_id": "{{ ti.xcom_pull(task_ids='get_audit_id', key='audit_id') }}"},
    task_id='extract_orderline',
    dag=dag,
    pool='postgres_dwh')

get_auditid >> extract_orderinfo >> extract_orderline


if __name__ == "__main__":
    dag.cli()
