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

import pyodbc

from airflow.hooks.dbapi_hook import DbApiHook


class MsSqlHook(DbApiHook):
    """
    Interact with Microsoft SQL Server.
    """

    conn_name_attr = 'mssql_conn_id'
    default_conn_name = 'mssql_default'
    supports_autocommit = True

    def __init__(self, *args, **kwargs):
        super(MsSqlHook, self).__init__(*args, **kwargs)
        self.schema = kwargs.pop("schema", None)
        self.conn = None

    def get_conn(self):
        """
        Returns a mssql connection object
        """
        if self.conn:
            return self.conn

        conn = self.get_connection(self.mssql_conn_id)
        conn_str = "DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={0};PORT={1};DATABASE={2};UID={3};PWD={4}".format(conn.host, conn.port, conn.schema, conn.login, conn.password)
        self.conn = pyodbc.connect(conn_str)
        return self.conn

    def set_autocommit(self, conn, autocommit):
        conn.autocommit = autocommit
