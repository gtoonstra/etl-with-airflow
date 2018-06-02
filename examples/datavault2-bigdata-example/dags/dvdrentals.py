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
from acme.operators.pg_to_file_operator import StagePostgresToFileOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.models import Variable


args = {
    'owner': 'airflow',
    'start_date': datetime(2007, 2, 15),
    'end_date': datetime(2007, 5, 15),
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


staging_done = DummyOperator(
    task_id='staging_done',
    dag=dag)


def stage_table(pg_table, downstream, override_cols=None, dtm_attribute=None):
    t1 = StagePostgresToFileOperator(
        source='dvdrentals',
        pg_table=pg_table,
        dtm_attribute=dtm_attribute,
        override_cols=override_cols,
        postgres_conn_id='dvdrentals',
        file_conn_id='filestore',
        task_id=pg_table,
        dag=dag)
    t1 >> downstream


stage_table(pg_table='public.actor', downstream=staging_done)
stage_table(pg_table='public.address', downstream=staging_done)
stage_table(pg_table='public.category', downstream=staging_done)
stage_table(pg_table='public.city', downstream=staging_done)
stage_table(pg_table='public.country', downstream=staging_done)
stage_table(pg_table='public.customer', downstream=staging_done)
stage_table(pg_table='public.film', downstream=staging_done)
stage_table(pg_table='public.film_actor', downstream=staging_done)
stage_table(pg_table='public.film_category', downstream=staging_done)
stage_table(pg_table='public.inventory', downstream=staging_done)
stage_table(pg_table='public.language', downstream=staging_done)
stage_table(pg_table='public.payment', downstream=staging_done, dtm_attribute='payment_date')
stage_table(pg_table='public.rental', downstream=staging_done)
stage_table(pg_table='public.staff', downstream=staging_done, override_cols=[
    'staff_id', 'first_name', 'last_name', 'address_id', 'email', 'store_id', 'active', 'last_update'])
stage_table(pg_table='public.store', downstream=staging_done)


if __name__ == "__main__":
    dag.cli()
