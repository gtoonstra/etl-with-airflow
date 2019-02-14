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
from acme.hooks.sqoop_hook import SqoopHook
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


DVDRENTALS_STAGING = 'staging_dvdrentals'
DATAVAULT = 'dv_raw'
DV_TEMP = 'dv_temp'
DV_STAR = 'dv_star'


def copy_jar():
    hook = SqoopHook(conn_id='sqoop_dvdrentals')
    hook.copy_file('/usr/lib/hive/lib/md5-1.0-SNAPSHOT.jar', 'usr/lib/hive/lib/md5-1.0-SNAPSHOT.jar')

def init_datavault2_bigdata_example():
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
                     "extra": json.dumps({"path": "/tmp/datavault2-bigdata-example"})})

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
                    {"conn_id": "hive_dvdrentals_staging",
                     "conn_type": "hive_cli",
                     "host": "hive",
                     "schema": DVDRENTALS_STAGING,
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

    create_new_conn(session,
                    {"conn_id": "sqoop_dvdrentals",
                     "host": "jdbc:postgresql://postgres",
                     "port": 5432,
                     "schema": "dvdrentals",
                     "login": "oltp_read",
                     "password": "oltp_read",
                     "conn_type": "sqoop"})

    session.close()

dag = airflow.DAG(
    'init_datavault2_bigdata_example',
    schedule_interval="@once",
    default_args=args,
    template_searchpath='/usr/local/airflow/sql',
    max_active_runs=1)

t1 = PythonOperator(task_id='init_datavault2_bigdata_example',
                    python_callable=init_datavault2_bigdata_example,
                    provide_context=False,
                    dag=dag)

t2 = HiveOperator(task_id='create_stg_database',
                  hive_cli_conn_id='hive_default',
                  schema='default',
                  hql='CREATE DATABASE IF NOT EXISTS {0}'.format(DVDRENTALS_STAGING),
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

t6 = HiveOperator(task_id='create_function',
                  hive_cli_conn_id='hive_default',
                  schema='default',
                  hql="CREATE FUNCTION Md5 AS 'org.example.bigdata.Md5'",
                  dag=dag)


hubs_done = DummyOperator(
    task_id='hubs_done',
    dag=dag)
links_done = DummyOperator(
    task_id='links_done',
    dag=dag)
sats_done = DummyOperator(
    task_id='sats_done',
    dag=dag)
all_done = DummyOperator(
    task_id='all_done',
    dag=dag)

def create_object(hql, tablename, upstream, downstream):
    t = HiveOperator(task_id=tablename,
                     hive_cli_conn_id='hive_datavault_raw',
                     schema=DATAVAULT,
                     hql=hql,
                     dag=dag)
    upstream >> t
    t >> downstream


t1 >> t6 >> t2 >> t3 >> t4

# hubs
create_object(
    hql='ddl/hub_actor.hql',
    tablename='hub_actor',
    upstream=t4,
    downstream=hubs_done)
create_object(
    hql='ddl/hub_category.hql',
    tablename='hub_category',
    upstream=t4,
    downstream=hubs_done)
create_object(
    hql='ddl/hub_customer.hql',
    tablename='hub_customer',
    upstream=t4,
    downstream=hubs_done)
create_object(
    hql='ddl/hub_film.hql',
    tablename='hub_film',
    upstream=t4,
    downstream=hubs_done)
create_object(
    hql='ddl/hub_inventory.hql',
    tablename='hub_inventory',
    upstream=t4,
    downstream=hubs_done)
create_object(
    hql='ddl/hub_language.hql',
    tablename='hub_language',
    upstream=t4,
    downstream=hubs_done)
create_object(
    hql='ddl/hub_rental.hql',
    tablename='hub_rental',
    upstream=t4,
    downstream=hubs_done)
create_object(
    hql='ddl/hub_staff.hql',
    tablename='hub_staff',
    upstream=t4,
    downstream=hubs_done)
create_object(
    hql='ddl/hub_store.hql',
    tablename='hub_store',
    upstream=t4,
    downstream=hubs_done)

# links
create_object(
    hql='ddl/link_customer_store.hql',
    tablename='link_customer_store',
    upstream=hubs_done,
    downstream=links_done)
create_object(
    hql='ddl/link_film_actor.hql',
    tablename='link_film_actor',
    upstream=hubs_done,
    downstream=links_done)
create_object(
    hql='ddl/link_film_category.hql',
    tablename='link_film_category',
    upstream=hubs_done,
    downstream=links_done)
create_object(
    hql='ddl/link_film_language.hql',
    tablename='link_film_language',
    upstream=hubs_done,
    downstream=links_done)
create_object(
    hql='ddl/link_inventory_film_store.hql',
    tablename='link_inventory_film_store',
    upstream=hubs_done,
    downstream=links_done)
create_object(
    hql='ddl/link_payment.hql',
    tablename='link_payment',
    upstream=hubs_done,
    downstream=links_done)
create_object(
    hql='ddl/link_rental_transaction.hql',
    tablename='link_rental_customer',
    upstream=hubs_done,
    downstream=links_done)
create_object(
    hql='ddl/link_staff_store.hql',
    tablename='link_staff_store',
    upstream=hubs_done,
    downstream=links_done)
create_object(
    hql='ddl/link_store_manager.hql',
    tablename='link_store_manager',
    upstream=hubs_done,
    downstream=links_done)

# satellites
create_object(
    hql='ddl/sat_customer.hql',
    tablename='sat_customer',
    upstream=links_done,
    downstream=sats_done)
create_object(
    hql='ddl/sat_film.hql',
    tablename='sat_film',
    upstream=links_done,
    downstream=sats_done)
create_object(
    hql='ddl/sat_payment.hql',
    tablename='sat_payment',
    upstream=links_done,
    downstream=sats_done)
create_object(
    hql='ddl/sat_rental.hql',
    tablename='sat_rental',
    upstream=links_done,
    downstream=sats_done)
create_object(
    hql='ddl/sat_staff.hql',
    tablename='sat_staff',
    upstream=links_done,
    downstream=sats_done)

# views over satellites
create_object(
    hql='ddl/vw_sat_customer.hql',
    tablename='vw_sat_customer',
    upstream=sats_done,
    downstream=all_done)
create_object(
    hql='ddl/vw_sat_film.hql',
    tablename='vw_sat_film',
    upstream=sats_done,
    downstream=all_done)
create_object(
    hql='ddl/vw_sat_payment.hql',
    tablename='vw_sat_payment',
    upstream=sats_done,
    downstream=all_done)
create_object(
    hql='ddl/vw_sat_rental.hql',
    tablename='vw_sat_rental',
    upstream=sats_done,
    downstream=all_done)
create_object(
    hql='ddl/vw_sat_staff.hql',
    tablename='vw_sat_staff',
    upstream=sats_done,
    downstream=all_done)
