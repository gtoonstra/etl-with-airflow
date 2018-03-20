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
from acme.operators.mssql_import_operator import MsSqlImportOperator
from airflow import models
from airflow.settings import Session
from airflow.models import Variable
import logging
import random
import string


args = {
    'owner': 'airflow',
    'start_date': airflow.utils.dates.days_ago(7),
    'provide_context': True
}

tmpl_search_path = Variable.get("sql_path")

dag = airflow.DAG(
    'bcp_example',
    schedule_interval="@once",
    default_args=args,
    template_searchpath=tmpl_search_path,
    max_active_runs=1)


def generate_synth_data(col_list):
    dataframe = []
    for i in range(0, 100000, 1):
        row = []
        for colname in col_list:
            if colname == 'region_id':
                row.append(random.randint(1, 500))
            if colname == 'region_name':
                val = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(10))
                row.append(val)
        dataframe.append(row)
    return dataframe


t1 = MsSqlImportOperator(task_id='import_data',
                         table_name='test.test',
                         generate_synth_data=generate_synth_data,
                         mssql_conn_id='mssql',
                         dag=dag)
