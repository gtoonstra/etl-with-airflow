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
from airflow.operators.hive_operator import HiveOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.models import Variable


args = {
    'owner': 'airflow',
    'start_date': airflow.utils.dates.days_ago(1),
    'provide_context': True,
    'depends_on_past': True
}

dag = airflow.DAG(
    'dvraw_enddating',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    template_searchpath='/usr/local/airflow/sql',
    default_args=args,
    max_active_runs=1)

enddating_done =  DummyOperator(
    task_id='enddating_done',
    dag=dag)

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

    step1 >> step2 >> step3
    step3 >> enddating_done

create_operator_array('postupdates/sat_address.hql', 'sat_address')
create_operator_array('postupdates/sat_creditcard.hql', 'sat_creditcard')
create_operator_array('postupdates/sat_currency.hql', 'sat_currency')
create_operator_array('postupdates/sat_person.hql', 'sat_person')
create_operator_array('postupdates/sat_product.hql', 'sat_product')
create_operator_array('postupdates/sat_salesorder.hql', 'sat_salesorder')
create_operator_array('postupdates/sat_salesordertail.hql', 'sat_salesordertail')
create_operator_array('postupdates/sat_salesreason.hql', 'sat_salesreason')
create_operator_array('postupdates/sat_salesterritory.hql', 'sat_salesterritory')
create_operator_array('postupdates/sat_shipmethod.hql', 'sat_shipmethod')


if __name__ == "__main__":
    dag.cli()
