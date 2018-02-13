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
import hashlib

from airflow.hooks.postgres_hook import PostgresHook
from acme.hooks.hive_hooks import HiveCliHook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
from datetime import datetime


class StagePostgresToHiveOperator(BaseOperator):
    """
    Moves data from Postgres to Hive. The operator runs your query against
    Postgres, stores the file locally before loading it into a Hive table.
    If the ``create`` or ``recreate`` arguments are set to ``True``,
    a ``CREATE TABLE`` and ``DROP TABLE`` statement is generated.
    Hive data types are inferred from the cursor's metadata. Note that the
    table generated in Hive uses ``STORED AS textfile``
    which isn't the most efficient serialization format. If a
    large amount of data is loaded and/or if the table gets
    queried considerably, you may want to use this operator only to
    stage the data into a temporary table before loading it into its
    final destination using a ``HiveOperator``.

    :param hive_table: target Hive table, use dot notation to target a
        specific database
    :type hive_table: str
    :param record_source: specifies the system source
    :type record_source: str
    :param load_dtm: specifies the system source
    :type load_dtm: datetime
    :param create: whether to create the table if it doesn't exist
    :type create: bool
    :param recreate: whether to drop and recreate the table at every
        execution
    :type recreate: bool
    :param delimiter: field delimiter in the file
    :type delimiter: str
    :param postgres_conn_id: source postgres connection
    :type postgres_conn_id: str
    :param hive_conn_id: destination hive connection
    :type hive_conn_id: str
    :param parameters: Parameters for the sql query
    :type parameters: dict
    """

    template_fields = ('sql', 'parameters', 'partition', 'hive_table', 'load_dtm')
    template_ext = ('.sql',)
    ui_color = '#ededed'

    @apply_defaults
    def __init__(
            self,
            sql,
            hive_table,
            record_source,
            load_dtm,
            create=True,
            recreate=False,
            partition=None,
            delimiter=chr(1),
            postgres_conn_id='postgres_default',
            hive_cli_conn_id='hive_cli_default',
            parameters=None,
            *args, **kwargs):
        super(StagePostgresToHiveOperator, self).__init__(*args, **kwargs)
        self.sql = sql
        self.hive_table = hive_table
        self.record_source = record_source
        self.load_dtm = load_dtm
        self.create = create
        self.recreate = recreate
        self.delimiter = str(delimiter)
        self.postgres_conn_id = postgres_conn_id
        self.hive_cli_conn_id = hive_cli_conn_id
        self.partition = partition
        self.parameters = parameters

    @classmethod
    def type_map(cls, field_name, postgres_type):
        d = {
            16: 'STRING', # BOOL
            20: 'INT',
            21: 'INT',
            23: 'INT',
            25: 'STRING',
            700: 'DOUBLE',
            701: 'DOUBLE',
            1114: 'TIMESTAMP',
            1082: 'DATE',
            1043: 'STRING',
            705: 'STRING',
            1700: 'DOUBLE'
        }
        if postgres_type not in d:
            raise Exception('Unrecognized data type {0} for field {1}'.format(postgres_type, field_name))

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
            fields_to_hash = set([])
            ctr = 0
            for field in cursor.description:
                field_dict[field[0]] = self.type_map(field[0], field[1])
                if field[0].startswith('hash_key'):
                    fields_to_hash.add(ctr)
                ctr += 1

            field_dict['rec_src'] = 'STRING'
            field_dict['load_dtm'] = 'TIMESTAMP'
            field_dict['seq_num'] = 'BIGINT'

            seq = long(1)
            for row in cursor:
                new_row = []
                for idx, val in enumerate(list(row)):
                    if idx in fields_to_hash:
                        m = hashlib.sha1()
                        m.update(val)
                        new_row.append(m.hexdigest().upper())
                    else:
                        new_row.append(val)

                csv_writer.writerow(new_row + [self.record_source, self.load_dtm, seq])
                seq += long(1)

            f.flush()
            cursor.close()
            conn.close()
            logging.info("Loading file into Hive")

            hive.load_file(
                f.name,
                self.hive_table,
                field_dict=field_dict,
                create=self.create,
                delimiter=self.delimiter,
                recreate=self.recreate,
                partition=self.partition)
