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
    'dvraw_starschema',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    template_searchpath='/usr/local/airflow/sql',
    default_args=args,
    max_active_runs=1)

dimensions_done =  DummyOperator(
    task_id='dimensions_done',
    dag=dag)
starschema_done =  DummyOperator(
    task_id='starschema_done',
    dag=dag)
dimensions_done >> starschema_done

def create_operator(hql, hive_table, prev_id, next_id):
    t = HiveOperator(
        hql=hql,
        hive_cli_conn_id='hive_datavault_raw',
        schema='dv_raw',
        task_id='star_{0}'.format(hive_table),
        dag=dag)
    t >> next_id
    if prev_id is not None:
        prev_id >> t

create_operator('starschema/dim_address.hql', 'dim_address', None, dimensions_done)
create_operator('starschema/dim_product.hql', 'dim_product', None, dimensions_done)
create_operator('starschema/dim_salesterritory.hql', 'dim_salesterritory', None, dimensions_done)
create_operator('starschema/dim_salesorder.hql', 'dim_salesorder', None, dimensions_done)
create_operator('starschema/fact_orderdetail.hql', 'fact_orderdetail', dimensions_done, starschema_done)

if __name__ == "__main__":
    dag.cli()
