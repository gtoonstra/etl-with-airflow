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

import os
import json
import logging
import tempfile

from airflow.contrib.hooks.gcs_hook import GoogleCloudStorageHook
from airflow.hooks.hive_hooks import HiveServer2Hook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults


class HiveToGcsOperator(BaseOperator):
    """
    Moves data from Hive to GCS.
    :param sql: SQL query to execute against the hive database
    :type sql: str
    :param bucket: target gcs bucket
    :type bucket: str
    :param subdir: target gcs location directory
    :type subdir: str
    :param file_pattern: Pattern for file naming
    :type file_pattern: str
    :param schema: hive database schema
    :type schema: str
    :param hiveserver2_conn_id: source hive connection
    :type hiveserver2_conn_id: str
    :param google_cloud_storage_conn_id: gcp connection
    :type google_cloud_storage_conn_id: str
    """

    template_fields = ('hql','subdir')
    template_ext = ('.hql',)
    ui_color = '#a0e08c'

    @apply_defaults
    def __init__(
            self,
            hql,
            bucket,
            subdir,
            file_pattern,
            schema='default',
            hiveserver2_conn_id='hiveserver2_default',
            google_cloud_storage_conn_id='gcp_default',
            *args, **kwargs):
        super(HiveToGcsOperator, self).__init__(*args, **kwargs)
        self.hql = hql
        self.schema = schema
        self.bucket = bucket
        self.subdir = subdir
        self.file_pattern = file_pattern
        self.hiveserver2_conn_id = hiveserver2_conn_id
        self.google_cloud_storage_conn_id = google_cloud_storage_conn_id

    def execute(self, context):
        hive = HiveServer2Hook(hiveserver2_conn_id=self.hiveserver2_conn_id)

        logging.info('Extracting data from Hive')
        logging.info(self.hql)

        data = hive.get_pandas_df(self.hql, schema=self.schema)
        gcp_hook = GoogleCloudStorageHook(google_cloud_storage_conn_id=self.google_cloud_storage_conn_id)
        logging.info('Inserting rows onto google cloud storage')

        f = tempfile.NamedTemporaryFile(suffix='.json', prefix='tmp')
        f.write(json.loads(data.to_json(orient='records')))
        f.flush()
        f.close()

        remote_file_name = self.file_pattern.format('aa')
        remote_name = os.path.join(self.subdir, remote_file_name)
        gcp_hook.upload(self.bucket, remote_name, f.name)

        logging.info('Done.')
