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
from datetime import datetime, timedelta
import os

import airflow
from airflow.operators.bash_operator import BashOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.models import Variable

from acme.operators.pg_to_file_operator import StagePostgresToFileOperator
from acme.operators.file_to_hive_operator import StageFileToHiveOperator
from airflow.operators.hive_operator import HiveOperator

args = {
    'owner': 'airflow',
    'start_date': datetime(2005, 5, 24),
    'end_date': datetime(2005, 8, 24),
    'provide_context': True,
    # We want to maintain chronological order when loading the datavault
    'depends_on_past': True
}

dag = airflow.DAG(
    'dvdrentals',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    template_searchpath='/usr/local/airflow/sql',
    default_args=args,
    max_active_runs=1)


extract_done = DummyOperator(
    task_id='extract_done',
    dag=dag)

daily_process_done = DummyOperator(
    task_id='daily_process_done',
    dag=dag)

staging_done = DummyOperator(
    task_id='staging_done',
    dag=dag)

loading_done = DummyOperator(
    task_id='loading_done',
    dag=dag)


def extract_entity(entity, incremental):
    t1 = StagePostgresToFileOperator(
        source='dvdrentals',
        sql='extract/{entity}.sql'.format(entity=entity),
        entity=entity,
        incremental=incremental,
        postgres_conn_id='dvdrentals',
        file_conn_id='filestore',
        task_id=entity,
        dag=dag)

    t1 >> extract_done


def create_staging_operator(hive_table):
    schemafile = os.path.join('file:///external', 'schema', 'avro', hive_table + '.avsc')
    t1 = StageFileToHiveOperator(
        hive_table=hive_table + '_{{ts_nodash}}',
        relative_file_path='incremental-load/dvdrentals/' + hive_table + '/{{ds[:4]}}/{{ds[5:7]}}/{{ds[8:10]}}/',
        schemafile=schemafile,
        create=True,
        recreate=True,
        file_conn_id='filestore',
        hive_cli_conn_id='hive_dvdrentals_staging',
        task_id='stage_{0}'.format(hive_table),
        dag=dag)

    daily_process_done >> t1 >> staging_done
    return t1


def load_hub(hql, hive_table):
    _, table = hive_table.split('.')

    t1 = HiveOperator(
        hql=hql,
        hive_cli_conn_id='hive_datavault_raw',
        schema='dv_raw',
        task_id='load_{0}'.format(hive_table),
        dag=dag)

    staging_done >> t1 >> loading_done
    return t1


def load_link(hql, hive_table):
    _, table = hive_table.split('.')

    t1 = HiveOperator(
        hql=hql,
        hive_cli_conn_id='hive_datavault_raw',
        schema='dv_raw',
        task_id='load_{0}'.format(hive_table),
        dag=dag)

    staging_done >> t1 >> loading_done
    return t1


def load_sat(hql, hive_table):
    _, table = hive_table.split('.')

    t1 = HiveOperator(
        hql=hql,
        hive_cli_conn_id='hive_datavault_raw',
        schema='dv_raw',
        task_id='load_{0}'.format(hive_table),
        dag=dag)

    staging_done >> t1 >> loading_done
    return t1

extract_entity(entity='public.customer', incremental=True)
extract_entity(entity='public.film', incremental=False)
extract_entity(entity='public.inventory', incremental=False)
extract_entity(entity='public.payment', incremental=True)
extract_entity(entity='public.rental', incremental=True)
extract_entity(entity='public.staff', incremental=False)
extract_entity(entity='public.store', incremental=False)

daily_dumps = BashOperator(
    bash_command='/usr/local/airflow/dataflow/process_daily_full_dumps.sh {{ts}}',
    task_id='daily_dumps',
    dag=dag)
incremental_build = BashOperator(
    bash_command='/usr/local/airflow/dataflow/start_incremental_dv.sh {{ts}}',
    task_id='incremental_build',
    dag=dag)

extract_done >> daily_dumps >> incremental_build >> daily_process_done


create_staging_operator('actor')
create_staging_operator('category')
create_staging_operator('customer')
create_staging_operator('film')
create_staging_operator('film_actor')
create_staging_operator('film_category')
create_staging_operator('film_language')
create_staging_operator('inventory')
create_staging_operator('inventory_film')
create_staging_operator('inventory_store')
create_staging_operator('language')
create_staging_operator('payment')
create_staging_operator('payment_rental')
create_staging_operator('rental')
create_staging_operator('rental_customer')
create_staging_operator('rental_inventory')
create_staging_operator('rental_staff')
create_staging_operator('staff')
create_staging_operator('staff_store')
create_staging_operator('store')

load_hub('loading/hub_actor.hql', 'dv_raw.hub_actor')
load_hub('loading/hub_category.hql', 'dv_raw.hub_category')
load_hub('loading/hub_customer.hql', 'dv_raw.hub_customer')
load_hub('loading/hub_film.hql', 'dv_raw.hub_film')
load_hub('loading/hub_inventory.hql', 'dv_raw.hub_inventory')
load_hub('loading/hub_language.hql', 'dv_raw.hub_language')
load_hub('loading/hub_rental.hql', 'dv_raw.hub_rental')
load_hub('loading/hub_staff.hql', 'dv_raw.hub_staff')
load_hub('loading/hub_store.hql', 'dv_raw.hub_store')

"""
load_link('loading/link_customer_store.hql', 'dv_raw.link_customer_store')
load_link('loading/link_film_actor.hql', 'dv_raw.link_film_actor')
load_link('loading/link_film_category.hql', 'dv_raw.link_film_category')
load_link('loading/link_film_language.hql', 'dv_raw.link_film_language')
load_link('loading/link_inventory_film.hql', 'dv_raw.link_inventory_film')
load_link('loading/link_inventory_store.hql', 'dv_raw.link_inventory_store')
load_link('loading/link_payment_customer.hql', 'dv_raw.link_payment_customer')
load_link('loading/link_payment_rental.hql', 'dv_raw.link_payment_rental')
load_link('loading/link_payment_staff.hql', 'dv_raw.link_payment_staff')
load_link('loading/link_rental_customer.hql', 'dv_raw.link_rental_customer')
load_link('loading/link_rental_inventory.hql', 'dv_raw.link_rental_inventory')
load_link('loading/link_staff_store.hql', 'dv_raw.link_staff_store')

load_sat('loading/sat_actor.hql', 'dv_raw.sat_actor')
load_sat('loading/sat_address.hql', 'dv_raw.sat_address')
load_sat('loading/sat_category.hql', 'dv_raw.sat_category')
load_sat('loading/sat_customer.hql', 'dv_raw.sat_customer')
load_sat('loading/sat_film.hql', 'dv_raw.sat_film')
load_sat('loading/sat_language.hql', 'dv_raw.sat_language')
load_sat('loading/sat_payment.hql', 'dv_raw.sat_payment')
load_sat('loading/sat_rental.hql', 'dv_raw.sat_rental')
load_sat('loading/sat_staff.hql', 'dv_raw.sat_staff')
load_sat('loading/sat_store.hql', 'dv_raw.sat_store')
"""


if __name__ == "__main__":
    dag.cli()
