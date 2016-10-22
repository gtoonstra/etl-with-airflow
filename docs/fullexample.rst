Full example
============

To demonstrate how the ETL principles come together with airflow, let's walk through a simple yet full
example that implements a data flow pipeline adhering to these principles. I'm mostly assuming that
people running airflow will have Linux (I use Ubuntu), but the examples should work for Mac OSX as
well with a couple of simple changes.

First, let's set up a simple postgres database that has a little bit of data, so that the example
can materialize in full and the processing becomes clear.

Install airflow
---------------

Follow `these <https://airflow.incubator.apache.org/start.html>`_ instructions for 
the quick start. After you start the webserver, also start the scheduler. Play around with it for while,
follow the tutorial there, then get back to this tutorial to further contextualize your understanding
of this platform.

Clone example project
---------------------

Go to the github project page of this documentation project, where you can download the example
source code, DAGs, SQL and scripts to generate the databases and load it with data:

`Documentation Github Project <https://github.com/gtoonstra/etl-with-airflow/>`_

Clone this project locally somewhere. 

Install postgres
----------------

Then first install postgres on your machine. For Ubuntu, this can be installed using apt: 

.. code-block:: bash

    $ sudo apt-get install postgresql
    $ sudo service postgresql restart

For Mac OSX, I highly recommend the `package installer <http://postgresapp.com/>`_. After installation,
it will be running and you can restart it after a reboot using the *app* in the launcher. You can log in
through the postgresql menu top right.

Set up database
---------------

On Linux, go to the *do-this-first* directory in the examples directory of the cloned github project,
then run the *create_everything.sh* script. For Mac OSX, you probably have to open the SQL scripts
separately and run them in order from the command line.

.. code-block:: bash

    $ cd examples/do-this-first
    $ ./create_everything.sh
    
Now, let's create some tables and populate it with some data.

.. code-block:: bash

    $ ./load_data.sh

Set up Postgres connection and pool
-----------------------------------

We need to declare this postgres connection in airflow. Go to the connections screen in the UI (through Admin)
and edit the default. Make sure to keep the connection string ID as *postgres_default*. You can check if this
connection is working for you in the *Ad-hoc query* section of the *Data Profiling* menu and select the same
connection string from there and doing a select on the order_info table:

::

    SELECT * FROM order_info;
    
Then add a pool to airflow (also under Admin) which is called *postgres_dwh*. 

Drop dags into airflow
----------------------

In a real setup you'd use continuous integration to update DAG's and dependencies in airflow after changes, 
but now we're going to drop in the lot straight into the DAG directory for simplicity.

.. code-block:: bash

    $ cd full-example/dags
    $ cp -R * $AIRFLOW_HOME/dags
    $ mkdir $AIRFLOW_HOME/sql
    $ cd full-example/sql
    $ cp *.sql $AIRFLOW_HOME/sql

Run it
------

In the airflow UI, refresh the main DAG UI and the new dags should be listed (orders_staging and orders_dwh). 
Probably the scheduler has already started executing the DAG, so go into the detail view for the DAG to see 
what the result were.

Proof of principles compliance
------------------------------

If we set principles for ourselves, we need to verify that we comply with them. This section documents how the
principles are implemented in the full example.

The *PostgresToPostgresOperator* uses a hook to acquire a connection to the source and destination database. 
The data corresponding to the execution date (which is here start of yesterday up to 
most recent midnight, but from the perspective of airflow that's *tomorrow*). There's code available in the example
to work with partitioned tables at the destination, but to keep the example concise and easily runnable, I decided 
to comment them out. Uncomment them and adjust the operators to put this back. The principle **Partition ingested data**
is not demonstrated by default for that reason; see the comment below for more information about the practice. 

**Load data incrementally** is satisfied by loading only the new created orders of yesterday.
**Process historic data** is possible by clearing the run; airflow will then reprocess the days that were cleared.
**Enforce the idempotency constraint** is satisfied, because the relevant data is cleared out prior to reloading it.
**Rest data between tasks** is satisfied, because the data is in two persistent stores before and after the operator.
All operators use a pool identifier, so **Pool your resources** is also satisfied and **Manage login details in one place** 
is satisfied through the connection settings in the Admin menu. The DAGs do not have all code in the dag itself, but it uses
a set of generally available operators in the subdirectories, which means that **Develop your own workflow framework**
is also satisfied. Other principles not listed are not applicable.


.. important::
    The commented code shows how to use the package manager to keep the last 90 days in a partition and then 
    move partitions out to the master table as a retention strategy. Partition management is done through another
    scheduled function that runs daily and moves partitions around and creates new ones when required. What's not
    demonstrated is archiving, which happens after that and depends on the accepted archiving policy for your
    organization.

    The benefit of partitioning is that rerunning ingests is very easy and there's better parallellization of tasks
    in the DB engine. So ingest jobs get less in the way of each other. The downside is that there are many more tables
    and files to manage and this can slow down performance if too heavily used. So it's good for the largest of tables
    like orderline and invoiceline, but other tables should probably deal with a single master table.
    
    You do not want to reload data older than 90 days in that case, so another operator or function should be added that
    checks whether today-execution_date is greather than 90 and prohibits execution if that's the case. Not doing that would
    truncate a non-existing table. An alternative is to follow a different path that uses DELETE FROM on the master table instead.

Code for reference
------------------

.. code:: python

    from __future__ import print_function
    import airflow
    from datetime import datetime, timedelta
    from acme.operators.postgres_to_postgres import PostgresToPostgresOperator
    from acme.operators.postgres_to_postgres import AuditOperator

    seven_days_ago = datetime.combine(
        datetime.today() - timedelta(7),
        datetime.min.time())

    args = {
        'owner': 'airflow',
        'start_date': seven_days_ago,
        'provide_context': True
    }

    dag = airflow.DAG(
        'orders_staging',
        schedule_interval="@daily",
        dagrun_timeout=timedelta(minutes=60),
        template_searchpath='/home/gt/airflow/sql',
        default_args=args,
        max_active_runs=1)

    get_auditid = AuditOperator(
        task_id='get_audit_id',
        postgres_conn_id='postgres_dwh',
        audit_key="orders",
        cycle_dtm="{{ ts }}",
        dag=dag,
        pool='postgres_dwh')

    extract_orderinfo = PostgresToPostgresOperator(
        sql='select_order_info.sql',
        pg_table='staging.order_info',
        src_postgres_conn_id='postgres_oltp',
        dest_postgress_conn_id='postgres_dwh',
        pg_preoperator="DELETE FROM staging.order_info WHERE "
            "partition_dtm >= DATE '{{ ds }}' AND partition_dtm < DATE '{{ tomorrow_ds }}'",
        parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}",
                    "audit_id": "{{ ti.xcom_pull(task_ids='get_audit_id', key='audit_id') }}"},
        task_id='ingest_order',
        dag=dag,
        pool='postgres_dwh')

    extract_orderline = PostgresToPostgresOperator(
        sql='select_orderline.sql',
        pg_table='staging.orderline',
        src_postgres_conn_id='postgres_oltp',
        dest_postgress_conn_id='postgres_dwh',
        pg_preoperator="DELETE FROM staging.orderline WHERE "
            "partition_dtm >= DATE '{{ ds }}' AND partition_dtm < DATE '{{ tomorrow_ds }}'",
        parameters={"window_start_date": "{{ ds }}", "window_end_date": "{{ tomorrow_ds }}",
                    "audit_id": "{{ ti.xcom_pull(task_ids='get_audit_id', key='audit_id') }}"},
        task_id='ingest_orderline',
        dag=dag,
        pool='postgres_dwh')

    get_auditid >> extract_orderinfo >> extract_orderline


    if __name__ == "__main__":
        dag.cli()

And the code for the defined operators:
        
.. code:: python

    import logging

    from airflow.hooks.postgres_hook import PostgresHook
    from airflow.models import BaseOperator
    from airflow.utils.decorators import apply_defaults
    from datetime import datetime


    class PostgresToPostgresOperator(BaseOperator):
        """
        Executes sql code in a Postgres database and insert into another

        :param src_postgres_conn_id: reference to the source postgres database
        :type src_postgres_conn_id: string
        :param dest_postgress_conn_id: reference to the destination postgres database
        :type dest_postgress_conn_id: string
        :param sql: the sql code to be executed
        :type sql: Can receive a str representing a sql statement,
            a list of str (sql statements), or reference to a template file.
            Template reference are recognized by str ending in '.sql'
        :param parameters: a parameters dict that is substituted at query runtime.
        :type parameters: dict
        """

        template_fields = ('sql', 'parameters', 'pg_table', 'pg_preoperator', 'pg_postoperator')
        template_ext = ('.sql',)
        ui_color = '#ededed'

        @apply_defaults
        def __init__(
                self,
                sql,
                pg_table,
                src_postgres_conn_id='postgres_default',
                dest_postgress_conn_id='postgres_default',
                pg_preoperator=None,
                pg_postoperator=None,
                parameters=None,
                *args, **kwargs):
            super(PostgresToPostgresOperator, self).__init__(*args, **kwargs)
            self.sql = sql
            self.pg_table = pg_table
            self.src_postgres_conn_id = src_postgres_conn_id
            self.dest_postgress_conn_id = dest_postgress_conn_id
            self.pg_preoperator = pg_preoperator
            self.pg_postoperator = pg_postoperator
            self.parameters = parameters

        def execute(self, context):
            logging.info('Executing: ' + str(self.sql))
            src_pg = PostgresHook(postgres_conn_id=self.src_postgres_conn_id)
            dest_pg = PostgresHook(postgres_conn_id=self.dest_postgress_conn_id)

            logging.info("Transferring Postgres query results into other Postgres database.")
            conn = src_pg.get_conn()
            cursor = conn.cursor()
            cursor.execute(self.sql, self.parameters)

            if self.pg_preoperator:
                logging.info("Running Postgres preoperator")
                dest_pg.run(self.pg_preoperator)

            logging.info("Inserting rows into Postgres")

            dest_pg.insert_rows(table=self.pg_table, rows=cursor)

            if self.pg_postoperator:
                logging.info("Running Postgres postoperator")
                dest_pg.run(self.pg_postoperator)

            logging.info("Done.")


    class AuditOperator(BaseOperator):
        """
        Executes sql code in a Postgres database and insert into another

        :param postgres_conn_id: reference to the postgres database
        :type postgres_conn_id: string
        :param audit_key: The key to use in the audit table
        :type audit_key: string
        :param cycle_dtm: The dtm of the extraction cycle run (ds)
        :type cycle_dtm: datetime
        """

        template_fields = ('audit_key', 'cycle_dtm')
        ui_color = '#ededed'

        @apply_defaults
        def __init__(
                self,
                postgres_conn_id='postgres_default',
                audit_key=None,
                cycle_dtm=None,
                *args, **kwargs):
            super(AuditOperator, self).__init__(*args, **kwargs)
            self.postgres_conn_id = postgres_conn_id
            self.audit_key = audit_key
            self.cycle_dtm = cycle_dtm

        def execute(self, context):
            logging.info('Getting postgres hook object')
            hook = PostgresHook(postgres_conn_id=self.postgres_conn_id)

            logging.info("Acquiring lock and updating audit table.")
            conn = hook.get_conn()
            cursor = conn.cursor()
            cursor.execute("LOCK TABLE staging.audit_runs IN ACCESS EXCLUSIVE MODE")
            cursor.close()

            logging.info("Acquiring new audit number")
            cursor = conn.cursor()
            cursor.execute("SELECT COALESCE(MAX(audit_id), 0)+1 FROM staging.audit_runs WHERE "
                           "audit_key=%(audit_key)s", {"audit_key": self.audit_key})
            row = cursor.fetchone()
            cursor.close()
            audit_id = row[0]
            logging.info("Found audit id %d." % (audit_id))

            params = {"audit_id": audit_id, "audit_key": self.audit_key,
                      "exec_dtm": datetime.now(), "cycle_dtm": self.cycle_dtm}

            cursor = conn.cursor()
            logging.info("Updating audit table with audit id: %d" % (audit_id))
            cursor.execute("INSERT INTO staging.audit_runs "
                           "(audit_id, audit_key, execution_dtm, cycle_dtm) VALUES "
                           "(%(audit_id)s, %(audit_key)s, %(exec_dtm)s, %(cycle_dtm)s)",
                           params)
            conn.commit()
            cursor.close()
            conn.close()

            ti = context['ti']
            ti.xcom_push(key='audit_id', value=audit_id)

            return audit_id
