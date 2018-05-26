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
from airflow.operators.dummy_operator import DummyOperator
from airflow import models
from airflow.settings import Session
from airflow.models import Variable
import logging
import json


args = {
    'owner': 'airflow',
    'start_date': airflow.utils.dates.days_ago(7),
    'provide_context': True
}


ADVWORKS_STAGING = 'advworks_staging'
DATAVAULT = 'dv_raw'
DV_TEMP = 'dv_temp'
DV_STAR = 'dv_star'


def init_datavault3_example():
    logging.info('Creating connections, pool and sql path')

    session = Session()

    def create_new_conn(session, attributes):
        conn_id = attributes.get("conn_id")
        new_conn = session.query(models.Connection).filter(models.Connection.conn_id==conn_id).first()
        if not new_conn:
            logging.info("No connection found")
            new_conn = models.Connection()
        new_conn.conn_id = conn_id
        new_conn.conn_type = attributes.get('conn_type')
        new_conn.host = attributes.get('host')
        new_conn.port = attributes.get('port')
        new_conn.schema = attributes.get('schema')
        new_conn.login = attributes.get('login')
        new_conn.set_password(attributes.get('password'))
        new_conn.set_extra(attributes.get('extra'))

        session.merge(new_conn)
        session.commit()

    create_new_conn(session,
                    {"conn_id": "dvdrentals",
                     "conn_type": "postgres",
                     "host": "postgres",
                     "port": 5432,
                     "schema": "dvdrentals",
                     "login": "oltp_read",
                     "password": "oltp_read"})

    create_new_conn(session,
                    {"conn_id": "filestore",
                     "conn_type": "File",
                     "host": "",
                     "port": 0,
                     "schema": "",
                     "login": "",
                     "password": "",
                     "extra": json.dumps({"path": "/tmp/datavault3-example"})})

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
                         "auth": "noSasl",
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
                         "auth": "noSasl",
                         "use_beeline": "true"})})

    create_new_conn(session,
                    {"conn_id": "hive_datavault_temp",
                     "conn_type": "hive_cli",
                     "host": "hive",
                     "schema": 'dv_temp',
                     "port": 10000,
                     "login": "cloudera",
                     "password": "cloudera",
                     "extra": json.dumps(
                        {"hive_cli_params": "",
                         "auth": "noSasl",
                         "use_beeline": "true"})})

    create_new_conn(session,
                    {"conn_id": "hiveserver2-dvstar",
                     "conn_type": "hiveserver2",
                     "host": "hive",
                     "schema": 'dv_star',
                     "login": "cloudera",
                     "port": 10000,
                     "extra": json.dumps({"authMechanism": "NOSASL"})})

    session.close()

dag = airflow.DAG(
    'init_datavault3_example',
    schedule_interval="@once",
    default_args=args,
    template_searchpath='/usr/local/airflow/sql',
    max_active_runs=1)

t1 = PythonOperator(task_id='init_datavault3_example',
                    python_callable=init_datavault3_example,
                    provide_context=False,
                    dag=dag)

t2 = HiveOperator(task_id='create_stg_database',
                  hive_cli_conn_id='hive_default',
                  schema='default',
                  hql='CREATE DATABASE IF NOT EXISTS {0}'.format(ADVWORKS_STAGING),
                  dag=dag)

t3 = HiveOperator(task_id='create_dv_database',
                  hive_cli_conn_id='hive_default',
                  schema='default',
                  hql='CREATE DATABASE IF NOT EXISTS {0}'.format(DATAVAULT),
                  dag=dag)

t4 = HiveOperator(task_id='create_dv_temp',
                  hive_cli_conn_id='hive_default',
                  schema='default',
                  hql='CREATE DATABASE IF NOT EXISTS {0}'.format(DV_TEMP),
                  dag=dag)

hubs_done = DummyOperator(
    task_id='hubs_done',
    dag=dag)
links_done = DummyOperator(
    task_id='links_done',
    dag=dag)
all_done = DummyOperator(
    task_id='all_done',
    dag=dag)

def create_table(hql, tablename, upstream, downstream):
    t = HiveOperator(task_id='table_{0}'.format(tablename),
                      hive_cli_conn_id='hive_datavault_raw',
                      schema=DATAVAULT,
                      hql=hql,
                      dag=dag)
    upstream >> t
    t >> downstream


t1 >> t2 >> t3 >> t4

# hubs
create_table(
    hql='ddl/hub_actor.hql',
    tablename='hub_actor',
    upstream=t4,
    downstream=hubs_done)

# links
create_table(
    hql='ddl/link_actor_film.hql',
    tablename='link_actor_film',
    upstream=hubs_done,
    downstream=links_done)

# references
create_table(
    hql='ddl/ref_language.hql',
    tablename='ref_language',
    upstream=hubs_done,
    downstream=links_done)

# satellites
create_table(
    hql='ddl/sat_actor.hql',
    tablename='sat_actor',
    upstream=links_done,
    downstream=all_done)
