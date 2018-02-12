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
from tempfile import NamedTemporaryFile
import unicodecsv as csv
from collections import OrderedDict
import time

from airflow.hooks.postgres_hook import PostgresHook
from acme.hooks.hive_hooks import HiveCliHook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
from datetime import datetime


class PostgresToHiveOperator(BaseOperator):
    """
    Moves data from Postgres to Hive. The operator runs your query against
    Postgres, stores the file locally before loading it into a Hive table.
    If the ``create`` or ``recreate`` arguments are set to ``True``,
    a ``CREATE TABLE`` and ``DROP TABLE`` statements are generated.
    Hive data types are inferred from the cursor's metadata. Note that the
    table generated in Hive uses ``STORED AS textfile``
    which isn't the most efficient serialization format. If a
    large amount of data is loaded and/or if the table gets
    queried considerably, you may want to use this operator only to
    stage the data into a temporary table before loading it into its
    final destination using a ``HiveOperator``.

    :param sql: SQL query to execute against the MySQL database
    :type sql: str
    :param hive_table: target Hive table, use dot notation to target a
        specific database
    :type hive_table: str
    :param create: whether to create the table if it doesn't exist
    :type create: bool
    :param recreate: whether to drop and recreate the table at every
        execution
    :type recreate: bool
    :param partition: target partition as a dict of partition columns
        and values
    :type partition: dict
    :param delimiter: field delimiter in the file
    :type delimiter: str
    :param postgres_conn_id: source postgres connection
    :type postgres_conn_id: str
    :param hive_conn_id: destination hive connection
    :type hive_conn_id: str
    """

    template_fields = ('sql', 'parameters', 'partition', 'hive_table')
    template_ext = ('.sql',)
    ui_color = '#ededed'

    @apply_defaults
    def __init__(
            self,
            sql,
            hive_table,
            create=True,
            recreate=False,
            partition=None,
            delimiter=chr(1),
            postgres_conn_id='postgres_default',
            hive_cli_conn_id='hive_cli_default',
            parameters=None,
            *args, **kwargs):
        super(PostgresToHiveOperator, self).__init__(*args, **kwargs)
        self.sql = sql
        self.parameters = parameters
        self.hive_table = hive_table
        self.partition = partition
        self.create = create
        self.recreate = recreate
        self.delimiter = str(delimiter)
        self.postgres_conn_id = postgres_conn_id
        self.hive_cli_conn_id = hive_cli_conn_id
        self.partition = partition or {}

    @classmethod
    def type_map(cls, postgres_type):
        d = {
            16: 'STRING', # BOOL
            20: 'INT',
            21: 'INT',
            23: 'INT',
            700: 'DOUBLE',
            701: 'DOUBLE',
            1114: 'TIMESTAMP',
            1082: 'DATE',
            1043: 'STRING',
            705: 'STRING'
        }
        if postgres_type not in d:
            raise Exception('Unrecognized data type {0}'.format(postgres_type))

        return d[postgres_type]

    def execute(self, context):
        hive = HiveCliHook(hive_cli_conn_id=self.hive_cli_conn_id)
        pg = PostgresHook(postgres_conn_id=self.postgres_conn_id)

        logging.info("Dumping postgres query results to local file")
        conn = pg.get_conn()
        cursor = conn.cursor()
        cursor.execute(self.sql, self.parameters)
        with NamedTemporaryFile("wb") as f:
            csv_writer = csv.writer(f, delimiter=self.delimiter, encoding="utf-8")
            field_dict = OrderedDict()
            for field in cursor.description:
                field_dict[field[0]] = self.type_map(field[1])
            csv_writer.writerows(cursor)
            f.flush()
            cursor.close()
            conn.close()
            logging.info("Loading file into Hive")

            hive.load_file(
                f.name,
                self.hive_table,
                field_dict=field_dict,
                create=self.create,
                partition=self.partition,
                delimiter=self.delimiter,
                recreate=self.recreate)
