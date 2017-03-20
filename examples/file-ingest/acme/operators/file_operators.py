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

import os, fnmatch
import logging

from shutil import copyfile
from airflow.contrib.hooks.fs_hook import FSHook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
from datetime import datetime

# You can also make this format a parameter in the Operator, for example
# if you expect that you work with different intervals than "@daily". 
# Then you can introduce time components to have a finer grain for file storage.
DATE_FORMAT = '%Y%m%d'


class FileToPredictableLocationOperator(BaseOperator):
    """
    Picks up a file from somewhere and lands this in a predictable location elsewhere
    """
    template_fields = ('file_mask',)

    @apply_defaults
    def __init__(self,
                 src_conn_id,
                 dst_conn_id,
                 file_mask,
                 *args,
                 **kwargs):
        """
        :param src_conn_id: Hook with a conn id that points to the source directory.
        :type src_conn_id: string
        :param dst_conn_id: Hook with a conn id that points to the destination directory.
        :type dst_conn_id: string
        """
        super(FileToPredictableLocationOperator, self).__init__(*args, **kwargs)
        self.src_conn_id = src_conn_id
        self.dst_conn_id = dst_conn_id
        self.file_mask = file_mask

    def execute(self, context):
        """
        Picks up all files from a source directory and dumps them into a root directory system,
        organized by dagid, taskid and execution_date
        """
        execution_date = context['execution_date'].strftime(DATE_FORMAT)
        src_hook = FSHook(conn_id=self.src_conn_id)
        source_dir = src_hook.get_path()

        dest_hook = FSHook(conn_id=self.dst_conn_id)
        dest_root_dir = dest_hook.get_path()

        dag_id = self.dag.dag_id
        task_id = self.task_id

        logging.info("Now searching for files like {0} in {1}".format(self.file_mask, source_dir))
        file_names = fnmatch.filter(os.listdir(source_dir), self.file_mask)
        for file_name in file_names:
            full_path = os.path.join(source_dir, file_name)
            dest_dir = os.path.join(dest_root_dir, dag_id, task_id, execution_date)
            logging.info("Now creating path structure {0}".format(dest_dir))
            os.makedirs(dest_dir)
            dest_file_name = os.path.join(dest_dir, os.path.basename(file_name))
            logging.info("Now moving {0} to {1}".format(full_path, dest_file_name))
            copyfile(full_path, dest_file_name)


class PredictableLocationToFinalLocationOperator(BaseOperator):
    """
    Picks up a file from predictable location storage and loads/transfers the results to 
    a target system (in this case another directory, but it could be anywhere).
    """
    @apply_defaults
    def __init__(self,
                 src_conn_id,
                 dst_conn_id,
                 src_task_id,
                 *args,
                 **kwargs):
        """
        :param src_conn_id: Hook with a conn id that points to the source directory.
        :type src_conn_id: string
        :param dst_conn_id: Hook with a conn id that points to the destination directory.
        :type dst_conn_id: string
        :param src_task_id: Source task that produced the file of interest
        :type src_task_id: string
        """
        super(PredictableLocationToFinalLocationOperator, self).__init__(*args, **kwargs)
        self.src_conn_id = src_conn_id
        self.dst_conn_id = dst_conn_id
        self.src_task_id = src_task_id

    def execute(self, context):
        """
        Picks up all files from a source directory and dumps them into a root directory system,
        organized by dagid, taskid and execution_date
        """
        execution_date = context['execution_date'].strftime(DATE_FORMAT)
        src_hook = FSHook(conn_id=self.src_conn_id)
        dest_hook = FSHook(conn_id=self.dst_conn_id)
        dest_dir = dest_hook.get_path()

        dag_id = self.dag.dag_id

        source_dir = os.path.join(src_hook.get_path(), dag_id, self.src_task_id, execution_date)
        if os.path.exists(source_dir):
            for file_name in os.listdir(source_dir):
                full_path = os.path.join(source_dir, file_name)
                dest_file_name = os.path.join(dest_hook.get_path(), file_name)
                logging.info("Now moving {0} to final destination {1}".format(full_path, dest_file_name))
                copyfile(full_path, dest_file_name)
