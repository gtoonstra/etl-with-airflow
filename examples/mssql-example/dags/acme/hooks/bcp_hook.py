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

from airflow.hooks.dbapi_hook import DbApiHook
import subprocess


class BcpHook(DbApiHook):
    """
    Interact with Microsoft SQL Server through bcp
    """

    conn_name_attr = 'mssql_conn_id'
    default_conn_name = 'mssql_default'
    supports_autocommit = True

    def __init__(self, *args, **kwargs):
        super(BcpHook, self).__init__(*args, **kwargs)
        self.schema = kwargs.pop("schema", None)

    def get_conn(self):
        """
        Returns a mssql connection details object
        """
        return self.get_connection(self.mssql_conn_id)

    def run_bcp(self, cmd):
        self.log.info("Running command: {0}".format(cmd))
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        outs, errs = proc.communicate()
        self.log.info("Output:")
        print(outs)
        self.log.info("Stderr:")
        print(errs)
        if proc.returncode != 0:
            raise Exception("Process failed: {0}".format(proc.returncode))

    def add_conn_details(self, cmd, conn):
        conn_params = ['-S', conn.host, '-U', conn.login, '-P', conn.password, '-d', conn.schema]
        cmd.extend(conn_params)

    def generate_format_file(self, table_name, format_file):
        # Generate format file first:
        conn = self.get_conn()
        cmd = ['bcp', table_name, 'format', 'nul', '-c', '-f', format_file.name, '-t,']
        self.add_conn_details(cmd, conn)
        self.run_bcp(cmd)

    def import_data(self, format_file, data_file, table_name):
        # Generate format file first:
        conn = self.get_conn()
        cmd = ['bcp', table_name, 'in', data_file, '-f', format_file]
        self.add_conn_details(cmd, conn)
        self.run_bcp(cmd)
