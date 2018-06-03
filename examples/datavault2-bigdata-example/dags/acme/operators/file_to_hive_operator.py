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
import os

from acme.hooks.file_hook import FileHook
from acme.hooks.hive_hooks import HiveCliHook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
from datetime import datetime


class StageFileToHiveOperator(BaseOperator):
    """
    Moves data from File into Hive. The operator picks up all files of interest
    from storage.

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
    :param file_pattern: File pattern to pick up files from
    :type file_pattern: str
    :param create: whether to create the table if it doesn't exist
    :type create: bool
    :param recreate: whether to drop and recreate the table at every
        execution
    :type recreate: bool
    :param delimiter: field delimiter in the file
    :type delimiter: str
    :param file_conn_id: source postgres connection
    :type file_conn_id: str
    :param hive_conn_id: destination hive connection
    :type hive_conn_id: str
    :param parameters: Parameters for the sql query
    :type parameters: dict
    """

    template_fields = ('partition', 'hive_table', 'relative_file_path')
    ui_color = '#ededed'

    @apply_defaults
    def __init__(
            self,
            hive_table,
            relative_file_path,
            field_dict,
            create=True,
            recreate=False,
            partition=None,
            delimiter=chr(1),
            file_conn_id='file_default',
            hive_cli_conn_id='hive_cli_default',
            *args, **kwargs):
        super(StageFileToHiveOperator, self).__init__(*args, **kwargs)
        self.hive_table = hive_table
        self.relative_file_path = relative_file_path
        self.field_dict = field_dict
        self.create = create
        self.recreate = recreate
        self.delimiter = str(delimiter)
        self.file_conn_id = file_conn_id
        self.hive_cli_conn_id = hive_cli_conn_id
        self.partition = partition

    def execute(self, context):
        hive = HiveCliHook(hive_cli_conn_id=self.hive_cli_conn_id)
        file_hook = FileHook(file_conn_id=self.file_conn_id)
        abs_path = file_hook.complete_file_path(self.relative_file_path)

        logging.info("Retrieving file and loading into Hive")
        with NamedTemporaryFile("wb") as f:
            logging.info("Loading file into Hive")

            hive.load_file(
                abs_path,
                self.hive_table,
                field_dict=self.field_dict,
                create=self.create,
                delimiter=self.delimiter,
                recreate=self.recreate,
                partition=self.partition)
