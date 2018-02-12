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
from airflow.operators.dummy_operator import DummyOperator
from airflow.models import Variable


args = {
    'owner': 'airflow',
    'start_date': airflow.utils.dates.days_ago(7),
    'provide_context': True
}

tmpl_search_path = Variable.get("sql_path")

dag = airflow.DAG(
    'datavault_staging',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    template_searchpath=tmpl_search_path,
    default_args=args,
    max_active_runs=1)

staging_done = DummyOperator(
    task_id='staging_done',
    dag=dag)


def create_staging_operator(sql, hive_table, include_cols=None, exclude_cols=None):
    t1 = StagePostgresToHiveOperator(
        sql=sql,
        hive_table=hive_table,
        postgres_conn_id='adventureworks',
        hive_cli_conn_id='hive_staging',
        include_cols=include_cols,
        exclude_cols=exclude_cols,
        create=True,
        recreate=True,
        task_id='stg_{0}'.format(hive_table),
        dag=dag)
    
    t1 >> staging_done
    return t1


create_staging_operator('salesorderheader.sql', 'salesorderheader', exclude_cols=['comment', 'rowguid', 'modifieddate'])

if __name__ == "__main__":
    dag.cli()
