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
from acme.operators.mssql_operator import MsSqlOperator
from airflow import models
from airflow.settings import Session
from airflow.models import Variable
import logging


args = {
    'owner': 'airflow',
    'start_date': airflow.utils.dates.days_ago(7),
    'provide_context': True
}

tmpl_search_path = Variable.get("sql_path")

dag = airflow.DAG(
    'create_mssql',
    schedule_interval="@once",
    default_args=args,
    template_searchpath=tmpl_search_path,
    max_active_runs=1)

t1 = MsSqlOperator(task_id='create_schema',
                   sql='create_schema.sql',
                   mssql_conn_id='mssql',
                   dag=dag)

t2 = MsSqlOperator(task_id='create_table',
                   sql='create_table.sql',
                   mssql_conn_id='mssql',
                   dag=dag)

t1 >> t2
