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
from airflow.operators.hive_operator import HiveOperator
from airflow import models
from airflow.settings import Session
import logging
import json


args = {
    'owner': 'airflow',
    'start_date': airflow.utils.dates.days_ago(7),
    'provide_context': True
}


ADVWORKS_STAGING = 'advworks_staging'
DATAVAULT = 'dv_raw'


def init_datavault2_example():
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
        new_conn.set_extra(attributes.get('extra'))
        new_conn.set_password(attributes.get('password'))

        session.add(new_conn)
        session.commit()

    create_new_conn(session,
                    {"conn_id": "adventureworks",
                     "conn_type": "postgres",
                     "host": "postgres",
                     "port": 5432,
                     "schema": "adventureworks",
                     "login": "oltp_read",
                     "password": "oltp_read"})

    create_new_conn(session,
                    {"conn_id": "hive_default",
                     "conn_type": "hive_cli",
                     "host": "hive",
                     "schema": "default",
                     "port": 10000,
                     "login": "cloudera",
                     "password": "cloudera",
                     "extra": json.dumps(
                        {"hive_cli_params": "",
                         "auth": "none",
                         "use_beeline": "true"})})

    create_new_conn(session,
                    {"conn_id": "hive_advworks_staging",
                     "conn_type": "hive_cli",
                     "host": "hive",
                     "schema": ADVWORKS_STAGING,
                     "port": 10000,
                     "login": "cloudera",
                     "password": "cloudera",
                     "extra": json.dumps(
                        {"hive_cli_params": "",
                         "auth": "none",
                         "use_beeline": "true"})})

    create_new_conn(session,
                    {"conn_id": "hive_datavault_raw",
                     "conn_type": "hive_cli",
                     "host": "hive",
                     "schema": DATAVAULT,
                     "port": 10000,
                     "login": "cloudera",
                     "password": "cloudera",
                     "extra": json.dumps(
                        {"hive_cli_params": "",
                         "auth": "none",
                         "use_beeline": "true"})})

    new_var = models.Variable()
    new_var.key = "sql_path"
    new_var.set_val("/usr/local/airflow/sql")
    session.add(new_var)
    new_var = models.Variable()
    new_var.key = "hql_path"
    new_var.set_val("/usr/local/airflow/hql")
    session.add(new_var)
    session.commit()

    session.close()

dag = airflow.DAG(
    'init_datavault2_example',
    schedule_interval="@once",
    default_args=args,
    max_active_runs=1)

t1 = PythonOperator(task_id='init_datavault2_example',
                    python_callable=init_datavault2_example,
                    provide_context=False,
                    dag=dag)

t2 = HiveOperator(task_id='create_stg_database',
                  hive_cli_conn_id='hive_default',
                  schema='default',
                  hql='CREATE DATABASE IF NOT EXISTS {0}'.format(ADVWORKS_STAGING),
                  dag=dag)

t2 = HiveOperator(task_id='create_dv_database',
                  hive_cli_conn_id='hive_default',
                  schema='default',
                  hql='CREATE DATABASE IF NOT EXISTS {0}'.format(DATAVAULT),
                  dag=dag)
