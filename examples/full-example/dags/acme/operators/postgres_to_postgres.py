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

import logging
import time
from random import random

from airflow.hooks.postgres_hook import PostgresHook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults


class PostgresToPostgresOperator(BaseOperator):
    """
    Executes sql code in a Postgres database and insert into another

    :param src_postgres_conn_id: reference to the source postgres database
    :type src_postgres_conn_id: string
    :param dest_postgress_conn_id: reference to the destination postgres database
    :type dest_postgress_conn_id: string
    :param sql: the sql code to be executed
    :type sql: Can receive a str representing a sql statement,
        a list of str (sql statements), or reference to a template file.
        Template reference are recognized by str ending in '.sql'
    :param parameters: a parameters dict that is substituted at query runtime.
    :type parameters: dict
    """

    template_fields = ('sql','parameters')
    template_ext = ('.sql',)
    ui_color = '#ededed'

    @apply_defaults
    def __init__(
            self, 
            sql,
            pg_table,
            src_postgres_conn_id='postgres_default', 
            dest_postgress_conn_id='postgres_default',
            pg_preoperator=None,
            pg_postoperator=None,
            parameters=None,
            *args, **kwargs):
        super(PostgresToPostgresOperator, self).__init__(*args, **kwargs)
        self.sql = sql
        self.pg_table = pg_table
        self.src_postgres_conn_id = src_postgres_conn_id
        self.dest_postgress_conn_id = dest_postgress_conn_id
        self.pg_preoperator = pg_preoperator
        self.pg_postoperator = pg_postoperator
        self.parameters = parameters

    def execute(self, context):
        logging.info('Executing: ' + str(self.sql))
        src_pg = PostgresHook(postgres_conn_id=self.src_postgres_conn_id)
        dest_pg = PostgresHook(postgres_conn_id=self.dest_postgress_conn_id)

        logging.info("Transferring Postgres query results into other Postgres database.")
        conn = src_pg.get_conn()
        cursor = conn.cursor()
        cursor.execute(self.sql, self.parameters)

        if self.pg_preoperator:
            logging.info("Running Postgres preoperator")
            dest_pg.run(self.pg_preoperator)

        time.sleep(5*random())

        logging.info("Inserting rows into Postgres")

        dest_pg.insert_rows(table=self.pg_table, rows=cursor)

        if self.pg_postoperator:
            logging.info("Running Postgres postoperator")
            dest_pg.run(self.pg_postoperator)

        logging.info("Done.")

