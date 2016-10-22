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

from airflow.hooks.postgres_hook import PostgresHook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
from datetime import datetime


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

    template_fields = ('sql', 'parameters', 'pg_table', 'pg_preoperator', 'pg_postoperator')
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

        logging.info("Inserting rows into Postgres")

        dest_pg.insert_rows(table=self.pg_table, rows=cursor)

        if self.pg_postoperator:
            logging.info("Running Postgres postoperator")
            dest_pg.run(self.pg_postoperator)

        logging.info("Done.")


class PostgresOperatorWithTemplatedParams(BaseOperator):
    """
    Executes sql code in a specific Postgres database

    :param postgres_conn_id: reference to a specific postgres database
    :type postgres_conn_id: string
    :param sql: the sql code to be executed
    :type sql: Can receive a str representing a sql statement,
        a list of str (sql statements), or reference to a template file.
        Template reference are recognized by str ending in '.sql'
    """

    template_fields = ('sql', 'parameters')
    template_ext = ('.sql',)
    ui_color = '#ededed'

    @apply_defaults
    def __init__(
            self, sql,
            postgres_conn_id='postgres_default', autocommit=False,
            parameters=None,
            *args, **kwargs):
        super(PostgresOperatorWithTemplatedParams, self).__init__(*args, **kwargs)
        self.sql = sql
        self.postgres_conn_id = postgres_conn_id
        self.autocommit = autocommit
        self.parameters = parameters

    def execute(self, context):
        logging.info('Executing: ' + str(self.sql))
        self.hook = PostgresHook(postgres_conn_id=self.postgres_conn_id)
        self.hook.run(self.sql, self.autocommit, parameters=self.parameters)


class AuditOperator(BaseOperator):
    """
    Executes sql code in a Postgres database and insert into another

    :param postgres_conn_id: reference to the postgres database
    :type postgres_conn_id: string
    :param audit_key: The key to use in the audit table
    :type audit_key: string
    :param cycle_dtm: The dtm of the extraction cycle run (ds)
    :type cycle_dtm: datetime
    """

    template_fields = ('audit_key', 'cycle_dtm')
    ui_color = '#ededed'

    @apply_defaults
    def __init__(
            self,
            postgres_conn_id='postgres_default',
            audit_key=None,
            cycle_dtm=None,
            *args, **kwargs):
        super(AuditOperator, self).__init__(*args, **kwargs)
        self.postgres_conn_id = postgres_conn_id
        self.audit_key = audit_key
        self.cycle_dtm = cycle_dtm

    def execute(self, context):
        logging.info('Getting postgres hook object')
        hook = PostgresHook(postgres_conn_id=self.postgres_conn_id)

        logging.info("Acquiring lock and updating audit table.")
        conn = hook.get_conn()
        cursor = conn.cursor()
        cursor.execute("LOCK TABLE staging.audit_runs IN ACCESS EXCLUSIVE MODE")
        cursor.close()

        logging.info("Acquiring new audit number")
        cursor = conn.cursor()
        cursor.execute("SELECT COALESCE(MAX(audit_id), 0)+1 FROM staging.audit_runs WHERE "
                       "audit_key=%(audit_key)s", {"audit_key": self.audit_key})
        row = cursor.fetchone()
        cursor.close()
        audit_id = row[0]
        logging.info("Found audit id %d." % (audit_id))

        params = {"audit_id": audit_id, "audit_key": self.audit_key,
                  "exec_dtm": datetime.now(), "cycle_dtm": self.cycle_dtm}

        cursor = conn.cursor()
        logging.info("Updating audit table with audit id: %d" % (audit_id))
        cursor.execute("INSERT INTO staging.audit_runs "
                       "(audit_id, audit_key, execution_dtm, cycle_dtm) VALUES "
                       "(%(audit_id)s, %(audit_key)s, %(exec_dtm)s, %(cycle_dtm)s)",
                       params)
        conn.commit()
        cursor.close()
        conn.close()

        ti = context['ti']
        ti.xcom_push(key='audit_id', value=audit_id)

        return audit_id
