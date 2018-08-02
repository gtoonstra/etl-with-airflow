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

import json
import logging
import os
import tempfile

from airflow.hooks.postgres_hook import PostgresHook
from acme.hooks.file_hook import FileHook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults


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
    :param sql: the sql to run against the source
    :type sql: str
    :param entity: The entity being created
    :type entity: str
    :param incremental: determines if this query does incremental loads
    :type incremental: bool
    :param postgres_conn_id: source postgres connection
    :type postgres_conn_id: str
    :param file_conn_id: destination hive connection
    :type file_conn_id: str
    """

    PG_DATETIME = "%Y-%m-%d %H:%M:%S"
    DV_LOAD_DTM = 'dv__load_dtm'
    DV_STATUS = 'dv__status'

    template_fields = ('sql', 'parameters')
    template_ext = ('.sql',)
    ui_color = '#ededed'

    @apply_defaults
    def __init__(
            self,
            source,
            sql,
            entity,
            incremental=False,
            parameters=None,
            postgres_conn_id='postgres_default',
            file_conn_id='file_default',
            *args, **kwargs):
        super(StagePostgresToFileOperator, self).__init__(*args, **kwargs)
        self.source = source
        self.sql = sql
        self.entity = entity
        self.incremental = incremental
        self.parameters = parameters
        self.postgres_conn_id = postgres_conn_id
        self.file_conn_id = file_conn_id

    def execute(self, context):
        file_hook = FileHook(file_conn_id=self.file_conn_id)
        pg_hook = PostgresHook(postgres_conn_id=self.postgres_conn_id)
        ds = context['execution_date']

        logging.info("Dumping postgres query results to local file")
        conn = pg_hook.get_conn()
        cursor = None

        cursor = conn.cursor()
        cursor.execute(self.sql, self.parameters)

        with tempfile.NamedTemporaryFile(prefix='abc', mode="wb", delete=True) as f:
            for row in cursor:
                jsonfield = row[0]
                jsonfield[StagePostgresToFileOperator.DV_LOAD_DTM] = ds.strftime('%Y-%m-%dT%H:%M:%S')
                if self.incremental:
                    jsonfield[StagePostgresToFileOperator.DV_STATUS] = 'NEW'
                f.write(json.dumps(jsonfield))
                f.write('\n')

            f.flush()
            cursor.close()
            conn.close()

            path = None
            if self.incremental:
                # Incremental loads go straight to psa
                path = os.path.join(
                    'psa',
                    self.source,
                    self.entity)
            else:
                # full dumps go to staging
                path = os.path.join(
                    'staging',
                    self.source,
                    self.entity)

            # Both roots add yyyy/mm/dd
            path = os.path.join(path,
                ds.strftime('%Y'),
                ds.strftime('%m'),
                ds.strftime('%d'))

            path = os.path.join(path, 
                self.entity + '__' + 
                ds.strftime('%H') + '-' + 
                ds.strftime('%M') + '-' +
                ds.strftime('%S'))
            file_hook.transfer_file(
                f.name,
                path)
