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
    'start_date': airflow.utils.dates.days_ago(7),
    'provide_context': True,
    'depends_on_past': True
}

tmpl_search_path = Variable.get("hive_sql_path")

# This dag needs to run in sequence to generate the correct results.
# It is dependent on the partitions in staging and then updates dimensions
# in chronological order. The HQL files of each step describe what that
# step does. Hive is "append-only", so the main strategy is to prepare a 
# completely new dimension that completely overwrites a current one.

# The steps are explicitly coded, you could build them dynamically using
# a simple for loop, because only the step id and the dimension name changes.

# Notice that customer and product are processed independently and in parallel
# in a single dag.

dag = airflow.DAG(
    'process_hive_dwh',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    template_searchpath=tmpl_search_path,
    default_args=args,
    max_active_runs=1)

customer_step_1 = HiveOperator(
    hql='customer/step_1.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='customer_step_1',
    dag=dag)

customer_step_2 = HiveOperator(
    hql='customer/step_2.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='customer_step_2',
    dag=dag)

customer_step_3 = HiveOperator(
    hql='customer/step_3.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='customer_step_3',
    dag=dag)

customer_step_4 = HiveOperator(
    hql='customer/step_4.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='customer_step_4',
    dag=dag)

customer_step_5 = HiveOperator(
    hql='customer/step_5.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='customer_step_5',
    dag=dag)

customer_step_6 = HiveOperator(
    hql='customer/step_6.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='customer_step_6',
    dag=dag)

customer_step_7 = HiveOperator(
    hql='customer/step_7.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='customer_step_7',
    dag=dag)

customer_step_8 = HiveOperator(
    hql='customer/step_8.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='customer_step_8',
    dag=dag)

customer_step_9 = HiveOperator(
    hql='customer/step_9.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='customer_step_9',
    dag=dag)


product_step_1 = HiveOperator(
    hql='product/step_1.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='product_step_1',
    dag=dag)

product_step_2 = HiveOperator(
    hql='product/step_2.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='product_step_2',
    dag=dag)

product_step_3 = HiveOperator(
    hql='product/step_3.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='product_step_3',
    dag=dag)

product_step_4 = HiveOperator(
    hql='product/step_4.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='product_step_4',
    dag=dag)

product_step_5 = HiveOperator(
    hql='product/step_5.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='product_step_5',
    dag=dag)

product_step_6 = HiveOperator(
    hql='product/step_6.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='product_step_6',
    dag=dag)

product_step_7 = HiveOperator(
    hql='product/step_7.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='product_step_7',
    dag=dag)

product_step_8 = HiveOperator(
    hql='product/step_8.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='product_step_8',
    dag=dag)

product_step_9 = HiveOperator(
    hql='product/step_9.hql',
    hive_cli_conn_id='hive_staging',
    schema='default',
    hiveconf_jinja_translate=True,
    task_id='product_step_9',
    dag=dag)

dummy = DummyOperator(
    task_id='dummy',
    dag=dag)

customer_step_1 >> customer_step_2 >> customer_step_3 >> customer_step_4
customer_step_4 >> customer_step_5 >> customer_step_6 >> customer_step_7 
customer_step_7 >> customer_step_8 >> customer_step_9

product_step_1 >> product_step_2 >> product_step_3 >> product_step_4
product_step_4 >> product_step_5 >> product_step_6 >> product_step_7 
product_step_7 >> product_step_8 >> product_step_9

customer_step_9 >> dummy
product_step_9 >> dummy


if __name__ == "__main__":
    dag.cli()
