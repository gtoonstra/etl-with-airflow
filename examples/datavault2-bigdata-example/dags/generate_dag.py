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

from __future__ import print_function
from datetime import datetime, timedelta
import os

import airflow
import yaml

from airflow.operators.python_operator import PythonOperator

# This is implemented as a DAG, but should become a tool in the CI/CD
# chain to generate avro schemas and dags for processing your data.

args = {
    'owner': 'airflow',
    'start_date': airflow.utils.dates.days_ago(7),
    'provide_context': True
}

dag = airflow.DAG(
    'generate_dag',
    schedule_interval="@once",
    default_args=args,
    max_active_runs=1)

TEMPLATE = """
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

from __future__ import print_function
from datetime import datetime, timedelta
import os

import airflow
from airflow.operators.bash_operator import BashOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.models import Variable

from airflow.operators.hive_operator import HiveOperator

from acme.operators.sqoop_operator import SqoopOperator
from acme.operators.file_to_hive_operator import StageAvroToHiveOperator
from airflow.operators.latest_only_operator import LatestOnlyOperator

args = {{
    'owner': 'airflow',
    'start_date': datetime(2005, 5, 24),
    'end_date': datetime(2005, 8, 24),
    'provide_context': True,
    # We want to maintain chronological order when loading the datavault
    'depends_on_past': True
}}

dag = airflow.DAG(
    '{subsystem}2',
    schedule_interval="@daily",
    dagrun_timeout=timedelta(minutes=60),
    template_searchpath='/usr/local/airflow/sql',
    default_args=args,
    max_active_runs=1)

extract_tasks = {{}}

staging_done = DummyOperator(
    task_id='staging_done',
    dag=dag)

hubs_done = DummyOperator(
    task_id='hubs_done',
    dag=dag)

links_done = DummyOperator(
    task_id='links_done',
    dag=dag)

def extract_entity(entity, columns=None, num_mappers=1, split_by=None, incremental=True):
    t1 = SqoopOperator(
        cmd_type='import',
        table=entity,
        file_type="avro",
        target_dir="{source}/" + entity + "/{{{{ts_nodash}}}}/",
        columns=columns,
        num_mappers=num_mappers,
        split_by=split_by,
        driver='org.postgresql.Driver',
        extra_import_options={{"connection-manager": "org.apache.sqoop.manager.GenericJdbcManager",
        "delete-target-dir": ""}},
        properties={{"mapreduce.cluster.local.dir": "/tmp/hadoop/" + entity}},
        out_dir="/tmp/sqoop/" + entity + "/{{{{ts_nodash}}}}/",
        avro_target_file="schemas/{source}/{{{{ts_nodash}}}}/" + entity + ".avsc",
        conn_id='sqoop_{source}',
        task_id=entity,
        dag=dag)

    return t1


def create_staging_op(entity, extract_task):
    _, hive_table = entity.split('.')
    schemafile = "/user/airflow/schemas/{source}/{{{{ts_nodash}}}}/" + entity + ".avsc"

    t1 = StageAvroToHiveOperator(
        hive_table=hive_table + '_{{{{ts_nodash}}}}',
        hdfs_dir='/user/airflow/{subsystem}/' + entity + '/{{{{ts_nodash}}}}/',
        schemafile=schemafile,
        create=True,
        recreate=True,
        hive_cli_conn_id='{staging}',
        task_id='stage_{{0}}'.format(hive_table),
        dag=dag)

    extract_task >> t1
    t1 >> staging_done
    return t1


def load_dv_table(hql, hive_table, upstream, downstream):
    t1 = HiveOperator(
        hql=hql,
        hive_cli_conn_id='hive_datavault_raw',
        schema='dv_raw',
        task_id='load_{{0}}'.format(hive_table),
        dag=dag)

    upstream >> t1 >> downstream
    return t1
"""

BIZ_KEY_SELECT = """LTRIM(RTRIM(COALESCE(CAST({alias}.{column} as string), '')))"""

HUB_TEMPLATE = """INSERT INTO TABLE dv_raw.hub_{hub_name}
SELECT DISTINCT
      Md5(CONCAT({biz_keys})) as hkey_{hub_name}
    , '{subsystem}' as rec_src
    , from_unixtime(unix_timestamp("{{{{ts_nodash}}}}", "yyyyMMdd'T'HHmmss")) as load_dtm
      {primary_key}
    , {columns}
FROM
    staging_{subsystem}.{table_name}_{{{{ts_nodash}}}} a
WHERE
    NOT EXISTS (
        SELECT 
                hub.hkey_{hub_name}
        FROM 
                dv_raw.hub_{hub_name} hub
        WHERE
                {where_stmt}
    )
"""

LINK_TEMPLATE = """INSERT INTO TABLE dv_raw.link_{link_name}
SELECT DISTINCT
      Md5(CONCAT({biz_keys})) as hkey_{link_name}
    , {col_list}
    , '{subsystem}' as rec_src
    , from_unixtime(unix_timestamp("{{{{ts_nodash}}}}", "yyyyMMdd'T'HHmmss")) as load_dtm
FROM
    staging_{subsystem}.{source_table}_{{{{ts_nodash}}}} a{joins}
WHERE
    NOT EXISTS (
        SELECT 
                link.hkey_{link_name}
        FROM    dv_raw.link_{link_name} link
        WHERE 
                {where_stmt}
    )
"""


def generate_dag():
    with open("schema/dvdrentals.yaml", "r") as stream:
        schema = yaml.load(stream)
        tables = schema['tables']
        links = schema['links']
        subsystem = schema['subsystem']
        hubs = {}

        with open("dags/{subsystem}2.py".format(subsystem=subsystem), "w") as f:
            f.write(TEMPLATE.format(source=schema['source'], staging=schema['staging'], subsystem=subsystem))
            f.write('\n')

            for table in tables:
                f.write('extract_tasks["{table_name}"] = extract_entity(entity="{table_name}", incremental={incremental}'.format(table_name=table['name'], incremental="True" if table.get('incremental') else "False"))
                if 'include_columns' in table:
                    f.write(', columns="{columns}"'.format(columns=','.join(table['include_columns'])))

                f.write(')\n')
                f.write('create_staging_op(entity="{table_name}", extract_task=extract_tasks["{table_name}"])\n'.format(table_name=table['name']))

                if 'hub_name' in table and 'business_key' in table:
                    _, table_name = table['name'].split(".")
                    hub_name = table['hub_name']
                    hubs[hub_name] = table

                    with open('sql/loading/hub_{hub_name}.hql'.format(hub_name=hub_name), 'w') as hub_file:
                        biz_keys = []
                        columns = []
                        where_stmt = []
                        primary_key = ", a." + table['primary_key'][0]

                        if table['primary_key'][0] in table['business_key']:
                            primary_key = ""

                        for column in table['business_key']:
                            biz_keys += [BIZ_KEY_SELECT.format(alias='a', column=column)]
                            columns += ['a.' + column]
                            where_stmt += ['    hub.' + column + ' = a.' + column + '\n']

                        biz_keys = " , '-' ,\n".join(biz_keys)
                        columns = "\n, ".join(columns)
                        where_stmt = "AND ".join(where_stmt)

                        hub_file.write(HUB_TEMPLATE.format(**locals()))

                    f.write("load_dv_table('loading/hub_{hub_name}.hql', 'hub_{hub_name}', staging_done, hubs_done)\n".format(hub_name=hub_name))

            for link in links:
                link_name = link['name']
                source_table = link['source']

                with open('sql/loading/link_{link_name}.hql'.format(link_name=link_name), 'w') as link_file:
                    biz_keys = []
                    col_list = []
                    where_stmt = []
                    joins = []
                    counter = 0
                    for ref in link['refs']:
                        alias = chr(ord('b') + counter)
                        table = hubs[ref]
                        # For now, only uses simple pk's, no composites
                        primary_key = table['primary_key'][0]
                        joins += ['\n  INNER JOIN dv_raw.hub_{ref} {alias} ON {alias}.{primary_key} = a.{primary_key}'.format(**locals())]
                        col_list += ['{alias}.hkey_{ref} as hkey_{ref}'.format(**locals())]
                        where_stmt += ['    link.hkey_' + ref + ' = ' + alias + '.hkey_' + ref + '\n']
                        counter += 1

                    biz_keys = " , '-' ,\n".join(biz_keys)
                    col_list = "\n, ".join(col_list)
                    where_stmt = "AND ".join(where_stmt)
                    joins = "".join(joins)

                    link_file.write(LINK_TEMPLATE.format(**locals()))

                    f.write("load_dv_table('loading/link_{link_name}.hql', 'link_{link_name}', hubs_done, links_done)\n".format(link_name=link_name))


t1 = PythonOperator(task_id='generate_dag',
                    python_callable=generate_dag,
                    provide_context=False,
                    dag=dag)
