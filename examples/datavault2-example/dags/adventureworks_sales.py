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
from acme.operators.hive_operators import StagePostgresToHiveOperator
from airflow.operators.hive_operator import HiveOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.models import Variable


args = {
    'owner': 'airflow',
    'start_date': airflow.utils.dates.days_ago(1),
    'provide_context': True,
    # We want to maintain chronological order when loading the datavault
    'depends_on_past': True
}

dag = airflow.DAG(
    'adventureworks_sales',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    template_searchpath='/usr/local/airflow/sql',
    default_args=args,
    max_active_runs=1)

RECORD_SOURCE = 'adventureworks.sales'

staging_done = DummyOperator(
    task_id='staging_done',
    dag=dag)
hubs_done = DummyOperator(
    task_id='hubs_done',
    dag=dag)
links_done = DummyOperator(
    task_id='links_done',
    dag=dag)
sats_done =  DummyOperator(
    task_id='sats_done',
    dag=dag)

# A function helps to generalize the parameters
def create_staging_operator(sql, hive_table, record_source=RECORD_SOURCE):
    t1 = StagePostgresToHiveOperator(
        sql=sql,
        hive_table=hive_table + '_{{ts_nodash}}',
        postgres_conn_id='adventureworks',
        hive_cli_conn_id='hive_advworks_staging',
        create=True,
        recreate=True,
        record_source=record_source,
        load_dtm='{{execution_date}}',
        task_id='stg_{0}'.format(hive_table),
        dag=dag)

    t1 >> staging_done
    return t1

def create_hub_operator(hql, hive_table):
    t1 = HiveOperator(
        hql=hql,
        hive_cli_conn_id='hive_datavault_raw',
        schema='dv_raw',
        task_id=hive_table,
        dag=dag)

    staging_done >> t1
    t1 >> hubs_done
    return t1

def create_link_operator(hql, hive_table):
    t1 = HiveOperator(
        hql=hql,
        hive_cli_conn_id='hive_datavault_raw',
        schema='dv_raw',
        task_id=hive_table,
        dag=dag)

    hubs_done >> t1
    t1 >> links_done
    return t1

def create_satellite_operator(hql, hive_table):
    t1 = HiveOperator(
        hql=hql,
        hive_cli_conn_id='hive_datavault_raw',
        schema='dv_raw',
        task_id=hive_table,
        dag=dag)

    links_done >> t1
    t1 >> sats_done
    return t1

# staging
create_staging_operator(sql='staging/creditcard.sql', hive_table='creditcard')
create_staging_operator(sql='staging/currency.sql', hive_table='currency')
create_staging_operator(sql='staging/currencyrate.sql', hive_table='currencyrate')
create_staging_operator(sql='staging/customer.sql', hive_table='customer')
create_staging_operator(sql='staging/salesorderdetail.sql', hive_table='salesorderdetail')
create_staging_operator(sql='staging/salesorderheader.sql', hive_table='salesorderheader')
create_staging_operator(sql='staging/salesorderheadersalesreason.sql', hive_table='salesorderheadersalesreason')
create_staging_operator(sql='staging/salesreason.sql', hive_table='salesreason')
create_staging_operator(sql='staging/salesterritory.sql', hive_table='salesterritory')
create_staging_operator(sql='staging/specialoffer.sql', hive_table='specialoffer')

# hubs
create_hub_operator('loading/hub_creditcard.hql', 'hub_creditcard')
create_hub_operator('loading/hub_currency.hql', 'hub_currency')
create_hub_operator('loading/hub_customer.hql', 'hub_customer')
create_hub_operator('loading/hub_salesorder.hql', 'hub_salesorder')
create_hub_operator('loading/hub_salesreason.hql', 'hub_salesreason')
create_hub_operator('loading/hub_salesterritory.hql', 'hub_salesterritory')
create_hub_operator('loading/hub_specialoffer.hql', 'hub_specialoffer')

# links
create_link_operator('loading/link_currencyrate.hql', 'link_currencyrate')
create_link_operator('loading/link_salesorderdetail.hql', 'link_salesorderdetail')
create_link_operator('loading/link_salesorderreason.hql', 'link_salesorderreason')
create_link_operator('loading/link_salesorderterritory.hql', 'link_salesorderterritory')

# satellites
create_satellite_operator('loading/sat_creditcard.hql', 'sat_creditcard')
create_satellite_operator('loading/sat_currency.hql', 'sat_currency')
create_satellite_operator('loading/sat_customer.hql', 'sat_customer')
create_satellite_operator('loading/sat_salesorder.hql', 'sat_salesorder')
create_satellite_operator('loading/sat_salesorderdetail.hql', 'sat_salesorderdetail')
create_satellite_operator('loading/sat_salesreason.hql', 'sat_salesreason')
create_satellite_operator('loading/sat_salesorderterritory.hql', 'sat_salesorderterritory')

if __name__ == "__main__":
    dag.cli()
