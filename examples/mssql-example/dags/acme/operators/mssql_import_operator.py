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

from acme.hooks.bcp_hook import BcpHook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
import tempfile
import csv


class MsSqlImportOperator(BaseOperator):
    """
    Imports synthethic data into a table on MSSQL
    """
    ui_color = '#ededed'

    @apply_defaults
    def __init__(
            self,
            table_name,
            generate_synth_data,
            mssql_conn_id='mssql_default',
            *args, **kwargs):
        super(MsSqlImportOperator, self).__init__(*args, **kwargs)
        self.mssql_conn_id = mssql_conn_id
        self.table_name = table_name
        self.generate_synth_data = generate_synth_data

    def get_column_list(self, format_file_name):
        col_list = []
        with open(format_file_name, 'r') as format_file:
            version = format_file.readline()
            num_cols = int(format_file.readline())
            for i in range(0, num_cols):
                new_col = format_file.readline()
                row = new_col.split(" ")
                row = [x for x in row if x is not '']
                col_list.append(row[6])
        return col_list

    def execute(self, context):
        hook = BcpHook(mssql_conn_id=self.mssql_conn_id)
        with tempfile.NamedTemporaryFile(prefix='format', delete=False) as format_file:
            self.log.info('Generating format file')
            hook.generate_format_file(self.table_name, format_file)
            self.log.info('Retrieving column list')
            col_list = self.get_column_list(format_file.name)
            self.log.info('Generating synthetic data using column list: {0}'.format(col_list))
            data = self.generate_synth_data(col_list)
            with tempfile.NamedTemporaryFile(prefix='data', mode='wb', delete=False) as data_file:
                self.log.info('Writing data to temp file')
                csv_writer = csv.writer(data_file, delimiter=',')
                csv_writer.writerows(data)
                data_file.flush()
                self.log.info('Importing data to SQL server')
                hook.import_data(format_file.name, data_file.name, self.table_name)
