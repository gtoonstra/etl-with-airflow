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
from airflow.operators.python_operator import PythonOperator
from airflow import models
from airflow.settings import Session
import logging


args = {
    'owner': 'airflow',
    'start_date': airflow.utils.dates.days_ago(7),
    'provide_context': True
}


def initialize_funcetl_example():
    logging.info('Creating connections, pool and sql path')

    session = Session()

    def create_new_conn(session, attributes):
        new_conn = models.Connection()
        new_conn.conn_id = attributes.get("conn_id")
        new_conn.conn_type = attributes.get('conn_type')
        new_conn.host = attributes.get('host')
        new_conn.port = attributes.get('port')
        new_conn.schema = attributes.get('schema')
        new_conn.login = attributes.get('login')
        new_conn.set_password(attributes.get('password'))

        session.add(new_conn)
        session.commit()

    create_new_conn(session,
                    {"conn_id": "oltp",
                     "conn_type": "postgres",
                     "host": "postgres",
                     "port": 5432,
                     "schema": "orders",
                     "login": "oltp_read",
                     "password": "oltp_read"})

    create_new_conn(session,
                    {"conn_id": "dwh",
                     "conn_type": "postgres",
                     "host": "postgres",
                     "port": 5432,
                     "schema": "dwh",
                     "login": "dwh_svc_account",
                     "password": "dwh_svc_account"})

    create_new_conn(session,
                    {"conn_id": "datavault",
                     "conn_type": "postgres",
                     "host": "postgres",
                     "port": 5432,
                     "schema": "datavault",
                     "login": "datavault_read",
                     "password": "datavault_read"})

    new_var = models.Variable()
    new_var.key = "sql_path"
    new_var.set_val("/usr/local/airflow/sql")
    session.add(new_var)
    session.commit()

    session.close()

dag = airflow.DAG(
    'init_funcetl_example',
    schedule_interval="@once",
    default_args=args,
    max_active_runs=1)

t1 = PythonOperator(task_id='init_funcetl_example',
                    python_callable=initialize_funcetl_example,
                    provide_context=False,
                    dag=dag)
