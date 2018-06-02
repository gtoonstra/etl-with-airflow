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
#

from __future__ import print_function

import os
import shutil

from airflow.exceptions import AirflowException
from airflow.hooks.base_hook import BaseHook
from airflow.utils.helpers import as_flattened_list
from airflow.utils.file import TemporaryDirectory


class FileHook(BaseHook):

    """ Hook to interact with file system
    """

    def __init__(self,
                 file_conn_id="file_default"):
        conn = self.get_connection(file_conn_id)
        self.path = conn.extra_dejson['path']

    def transfer_file(self, source_file, target_file):
        target_file = os.path.join(self.path, target_file)
        dirname = os.path.dirname(target_file)
        try:
            os.makedirs(dirname)
        except OSError as e:
            if e.errno != os.errno.EEXIST:
                raise
        shutil.copyfile(source_file, target_file)
