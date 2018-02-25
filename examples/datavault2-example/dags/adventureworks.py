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
    'adventureworks',
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
enddating_done =  DummyOperator(
    task_id='enddating_done',
    dag=dag)

staging_done >> hubs_done
hubs_done >> links_done
links_done >> sats_done
sats_done >> enddating_done

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


def create_operator_array(hql, hive_table):
    step1 = HiveOperator(
        hql='DROP TABLE IF EXISTS dv_temp.{0}_temp'.format(hive_table),
        hive_cli_conn_id='hive_datavault_raw',
        schema='dv_raw',
        task_id='drop_{0}'.format(hive_table),
        params={'hive_table': hive_table},
        dag=dag)

    step2 = HiveOperator(
        hql=hql,
        hive_cli_conn_id='hive_datavault_raw',
        schema='dv_raw',
        task_id='enddate_{0}'.format(hive_table),
        params={'hive_table': hive_table},
        dag=dag)

    step3 = HiveOperator(
        hql='INSERT OVERWRITE TABLE dv_raw.{0} SELECT * FROM dv_temp.{0}_temp'.format(hive_table),
        hive_cli_conn_id='hive_datavault_temp',
        schema='dv_temp',
        task_id='copyback_{0}'.format(hive_table),
        dag=dag)

    sats_done >> step1
    step1 >> step2 >> step3
    step3 >> enddating_done

# staging
create_staging_operator(sql='staging/address.sql', hive_table='address')
create_staging_operator(sql='staging/countryregion.sql', hive_table='countryregion')
create_staging_operator(sql='staging/creditcard.sql', hive_table='creditcard')
create_staging_operator(sql='staging/currency.sql', hive_table='currency')
create_staging_operator(sql='staging/currencyrate.sql', hive_table='currencyrate')
create_staging_operator(sql='staging/customer.sql', hive_table='customer')
create_staging_operator(sql='staging/person.sql', hive_table='person')
create_staging_operator(sql='staging/product.sql', hive_table='product')
create_staging_operator(sql='staging/salesorderdetail.sql', hive_table='salesorderdetail')
create_staging_operator(sql='staging/salesorderheader.sql', hive_table='salesorderheader')
create_staging_operator(sql='staging/salesorderheadersalesreason.sql', hive_table='salesorderheadersalesreason')
create_staging_operator(sql='staging/salesreason.sql', hive_table='salesreason')
create_staging_operator(sql='staging/salesterritory.sql', hive_table='salesterritory')
create_staging_operator(sql='staging/shipmethod.sql', hive_table='shipmethod')
create_staging_operator(sql='staging/specialoffer.sql', hive_table='specialoffer')
create_staging_operator(sql='staging/stateprovince.sql', hive_table='stateprovince')

# hubs
create_hub_operator('loading/hub_address.hql', 'hub_address')
create_hub_operator('loading/hub_creditcard.hql', 'hub_creditcard')
create_hub_operator('loading/hub_currency.hql', 'hub_currency')
create_hub_operator('loading/hub_customer.hql', 'hub_customer')
create_hub_operator('loading/hub_person.hql', 'hub_person')
create_hub_operator('loading/hub_product.hql', 'hub_product')
create_hub_operator('loading/ref_countryregion.hql', 'ref_countryregion')
create_hub_operator('loading/hub_salesorder.hql', 'hub_salesorder')
create_hub_operator('loading/hub_salesreason.hql', 'hub_salesreason')
create_hub_operator('loading/hub_salesterritory.hql', 'hub_salesterritory')
create_hub_operator('loading/hub_shipmethod.hql', 'hub_shipmethod')
create_hub_operator('loading/hub_specialoffer.hql', 'hub_specialoffer')
create_hub_operator('loading/hub_stateprovince.hql', 'hub_stateprovince')

# links
create_link_operator('loading/link_address_stateprovince.hql', 'link_address_stateprovince')
create_link_operator('loading/link_currencyrate.hql', 'link_currencyrate')
create_link_operator('loading/link_salesorder_address.hql', 'link_salesorder_address')
create_link_operator('loading/link_salesorder_creditcard.hql', 'link_salesorder_creditcard')
create_link_operator('loading/link_salesorder_currencyrate.hql', 'link_salesorder_currencyrate')
create_link_operator('loading/link_salesorderdetail.hql', 'link_salesorderdetail')
create_link_operator('loading/link_salesorderreason.hql', 'link_salesorderreason')
create_link_operator('loading/link_salesorder_shipmethod.hql', 'link_salesorder_shipmethod')
create_link_operator('loading/link_salesorderterritory.hql', 'link_salesorderterritory')

# satellites
create_satellite_operator('loading/sat_address.hql', 'sat_address')
create_satellite_operator('loading/sat_creditcard.hql', 'sat_creditcard')
create_satellite_operator('loading/sat_currency.hql', 'sat_currency')
create_satellite_operator('loading/sat_currencyrate.hql', 'sat_currencyrate')
create_satellite_operator('loading/sat_person.hql', 'sat_person')
create_satellite_operator('loading/sat_product.hql', 'sat_product')
create_satellite_operator('loading/sat_salesorder.hql', 'sat_salesorder')
create_satellite_operator('loading/sat_salesorderdetail.hql', 'sat_salesorderdetail')
create_satellite_operator('loading/sat_salesreason.hql', 'sat_salesreason')
create_satellite_operator('loading/sat_salesterritory.hql', 'sat_salesterritory')
create_satellite_operator('loading/sat_shipmethod.hql', 'sat_shipmethod')
create_satellite_operator('loading/sat_stateprovince.hql', 'sat_stateprovince')

# end dating
create_operator_array('postupdates/sat_address.hql', 'sat_address')
create_operator_array('postupdates/sat_creditcard.hql', 'sat_creditcard')
create_operator_array('postupdates/sat_currency.hql', 'sat_currency')
create_operator_array('postupdates/sat_currencyrate.hql', 'sat_currencyrate')
create_operator_array('postupdates/sat_person.hql', 'sat_person')
create_operator_array('postupdates/sat_product.hql', 'sat_product')
create_operator_array('postupdates/sat_salesorder.hql', 'sat_salesorder')
create_operator_array('postupdates/sat_salesorderdetail.hql', 'sat_salesorderdetail')
create_operator_array('postupdates/sat_salesreason.hql', 'sat_salesreason')
create_operator_array('postupdates/sat_salesterritory.hql', 'sat_salesterritory')
create_operator_array('postupdates/sat_shipmethod.hql', 'sat_shipmethod')
create_operator_array('postupdates/sat_stateprovince.hql', 'sat_stateprovince')


if __name__ == "__main__":
    dag.cli()
