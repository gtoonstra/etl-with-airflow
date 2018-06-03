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

import unicodecsv as csv
import logging
import os
import tempfile

from airflow.hooks.postgres_hook import PostgresHook
from acme.hooks.file_hook import FileHook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
from datetime import datetime


class StagePostgresToFileOperator(BaseOperator):
    """
    Moves data from Postgres to a file store. In this example, the file
    store is simply a directory in /tmp/datavault3-example on your computer
    (mapped using the yaml file). I believe it should even be possible to
    stream the file to the cloud instead of having to locally generate it
    and then transfer (should save I/O).

    The operator runs your query against Postgres and exports the result
    to the data lake structure that is predefined in this operator.

    By default it loads records from the postgres table filtered by date.
    If dtm_attribute is set, it will filter by the dtm of the execution date.
    If not set, it will load the whole table.
    The sql and parameters can be used to override the generated source query.

    :param source: string used to specify the source system
    :type source: str
    :param pg_table: pg_table to export
    :type pg_table: str
    :param dtm_attribute: The dtm attribute in the source table to filter on.
    :type dtm_attribute: str
    :param sql: the sql to run against the source
    :type sql: str
    :param load_dtm: specifies the load dtm.
    :type load_dtm: datetime
    :param delimiter: field delimiter in the file
    :type delimiter: str
    :param lineterminator: line terminator
    :type lineterminator: str
    :param postgres_conn_id: source postgres connection
    :type postgres_conn_id: str
    :param file_conn_id: destination hive connection
    :type file_conn_id: str
    """

    INFORMATION_LOOKUP = """
SELECT 
         column_name
FROM 
         information_schema.columns
WHERE 
         table_schema = '{0}'
AND      table_name   = '{1}'
ORDER BY ordinal_position
"""
    PG_DATETIME = "%Y-%m-%d %H:%M:%S"
    DV_LOAD_DTM = 'dv__load_dtm'

    template_fields = ('sql', 'parameters')
    template_ext = ('.sql',)
    ui_color = '#ededed'

    @apply_defaults
    def __init__(
            self,
            source,
            pg_table,
            dtm_attribute=None,
            override_cols=None,
            sql=None,
            parameters=None,
            delimiter=chr(1),
            line_terminator='\r\n',
            postgres_conn_id='postgres_default',
            file_conn_id='file_default',
            *args, **kwargs):
        super(StagePostgresToFileOperator, self).__init__(*args, **kwargs)
        self.source = source
        self.pg_table = pg_table
        self.dtm_attribute = dtm_attribute
        self.override_cols = override_cols
        self.sql = sql
        self.parameters = parameters
        self.delimiter = delimiter
        self.line_terminator = line_terminator
        self.postgres_conn_id = postgres_conn_id
        self.file_conn_id = file_conn_id

    def execute(self, context):
        file_hook = FileHook(file_conn_id=self.file_conn_id)
        pg_hook = PostgresHook(postgres_conn_id=self.postgres_conn_id)
        ds = context['execution_date']

        logging.info("Dumping postgres query results to local file")
        conn = pg_hook.get_conn()
        cursor = None

        if self.sql:
            cursor = conn.cursor()
            cursor.execute(self.sql, self.parameters)
        else:
            sql = self.generate_sql(pg_hook)
            logging.info(sql)
            cursor = conn.cursor()
            parameters = {
                "execution_date": context['execution_date'].strftime(StagePostgresToFileOperator.PG_DATETIME),
                "next_execution_date": context['next_execution_date'].strftime(StagePostgresToFileOperator.PG_DATETIME)}
            logging.info(parameters)
            cursor.execute(sql, parameters)

        fieldnames = [field[0] for field in cursor.description]
        fieldnames.append(StagePostgresToFileOperator.DV_LOAD_DTM)

        with tempfile.NamedTemporaryFile(prefix=self.pg_table, mode="wb", delete=True) as f:
            writer = csv.DictWriter(
                f, 
                delimiter=self.delimiter, 
                lineterminator=self.line_terminator,
                quoting=csv.QUOTE_NONE,
                quotechar='',
                encoding='utf-8',
                fieldnames=fieldnames)

            writer.writeheader()
            for row in cursor:
                dict_row = {}
                for key, value in zip(fieldnames, row):
                    dict_row[key] = value
                dict_row[StagePostgresToFileOperator.DV_LOAD_DTM] = ds
                writer.writerow(dict_row)

            f.flush()
            cursor.close()
            conn.close()

            path = os.path.join(
                'psa',
                self.source,
                self.pg_table)

            # With incremental loads, partition data per day.
            if self.sql or self.dtm_attribute:
                path = os.path.join(path,
                    ds.strftime('%Y'),
                    ds.strftime('%m'),
                    ds.strftime('%d'))

            path = os.path.join(path, 
                self.pg_table + '__' + 
                ds.strftime('%H') + '-' + 
                ds.strftime('%M') + '-' +
                ds.strftime('%S'))
            file_hook.transfer_file(
                f.name,
                path)

    def generate_sql(self, pg_hook):
        conn = pg_hook.get_conn()
        cursor = conn.cursor()

        fieldnames = []
        if self.override_cols:
            fieldnames = self.override_cols
        else:
            s = self.pg_table.split(".")
            cursor.execute(StagePostgresToFileOperator.INFORMATION_LOOKUP.format(s[0], s[1]))
            for row in cursor:
                fieldnames.append(row[0])

        if len(fieldnames) == 0:
            raise Exception("No fields to be selected, failed query")

        column_select = ','.join(fieldnames)
        sql = 'SELECT {0} FROM {1}'.format(column_select, self.pg_table)
        if self.dtm_attribute:
            sql += " WHERE {0} >= %(execution_date)s AND {0} < %(next_execution_date)s".format(
                self.dtm_attribute)
        return sql