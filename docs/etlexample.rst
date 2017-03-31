ETL example
===========

To demonstrate how the ETL principles come together with airflow, let's walk through a simple
example that implements a data flow pipeline adhering to these principles. I'm mostly assuming that
people running airflow will have Linux (I use Ubuntu), but the examples should work for Mac OSX as
well with a couple of simple changes.

First, let's set up a simple postgres database that has a little bit of data, so that the example
can materialize in full and the processing becomes clear.

Install airflow
---------------

Before we begin on this more elaborate example, `follow the tutorial <https://airflow.incubator.apache.org/start.html>`_ to
get acquainted with the basic principles. After you start the webserver, also start the scheduler. Play around with it for while,
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

Configure airflow
-----------------

We need to declare two postgres connections in airflow. 

Go to the connections screen in the UI (through Admin) and create a new postgres connection and call this
*postgres_oltp*. Then specify conntype=Postgres, Schema=orders, login=oltp_read (same password) and port 5432
or whatever you're using.

Then add another connection for Postgres, which connects to the data warehouse and call this *postgres_dwh*. Then specify conntype=Postgres, Schema=dwh, login=dwh_svc_account (same password) and port 5432.

You can check if these connections are working for you in the *Ad-hoc query* section of the 
*Data Profiling* menu. If the connections are in the connection drop down, the connection is failing because of a dependency issue or typo. If the connections show up, select the *postgres_oltp* connection string from there and doing a select on the order_info table:

::

    SELECT * FROM order_info;

Then add a pool to airflow (also under Admin) which should be called *postgres_dwh*. Let's give this a value of 10.

Finally add a Variable in the Variables section where the sql templates are stored; these are the SQL files 
from the example repository. Create a new variable "sql_path" and set the value to the directory.

Drop dags into airflow
----------------------

In a real setup you'd use continuous integration to update DAG's and dependencies in airflow after changes, 
but now we're going to drop in the lot straight into the DAG directory for simplicity.

.. code-block:: bash

    $ cd etl-example/dags
    $ cp -R * $AIRFLOW_HOME/dags
    $ mkdir $AIRFLOW_HOME/sql
    $ cd etl-example/sql
    $ cp *.sql $AIRFLOW_HOME/sql

Run it
------

In the airflow UI, refresh the main DAG UI and the new dags should be listed:

- orders_staging
- customer_staging
- product_staging
- process_dimensions
- process_order_fact

DAGs are inserted in a non-active state, so activate the DAGS and the scheduler should start running the jobs.
The process copies data from a toy OLTP data store: order_info, orderline, customer and product. 
Process_dimensions processes the product and customer dimensions using some Slowly Changing Dimensions with 
Type 2 logic and process_facts processes the fact tables.

How it works
------------

There are two databases created (on the same server) to simulate making a connection to a remote OLTP system
and another database which is a simplistic Data WareHouse. The OLTP system only has a couple of rows for orders,
orderlines and some customer and product info. 

The *_staging processes extract data from the OLTP database and ingest them into the staging tables in the staging
schema, taking care to make this process repeatable. Repeatable means removing data for the date window of consideration
first, then reinserting by issuing a select, only selecting the data that applies to the date window of interest.

The first thing you'd do when staging data is present is to process your dimensions. The *process_dimensions* DAG 
updates the customer and product dimensions in the data warehouse. Dimensions should be present before fact tables,
because there are foreign keys linking facts to dimensions and you need data to be there before you can link to it.

It is set up with the *depends_on_past* parameter set to True, because dimensions should be updated in a specific
sequence. This does have the effect that it can slow down the scheduling, because the task instances are now not
parallelized.

The *process_order_fact* processes the order+orderline data and associates them with the correct surrogate key in the
dimension tables, based on the date and time the dimension records were active and usually the business key.

Also notice how the dimension table update doesn't delete data from a specific window. Because of existing facts and 
how they link together, this is very dangerous to do! Instead, running the dimension multiple times leads to *no-ops* 
later, unless some extra data was added, leading to new records. Deletion of records is not implemented in this scenario,
which would lead to all versions for an entity having a specific end date.

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

Satisfied principles (not listed are not applicable):

- **Load data incrementally** : extracts only the newly created orders of the day before, not the whole table.
- **Process historic data** : it's possible to rerun the extract processes, but downstream DAGs have to be started manually.
- **Enforce the idempotency constraint** : every DAG cleans out data if required and possible. Rerunning the same DAG multiple 
  times has no undesirable side effects like duplication of the data.
- **Rest data between tasks** : The data is in persistent storage before and after the operator.
- **Pool your resources** : All task instances in the DAG use a pooled connection to the DWH by specifying the *pool* parameter.
- **Manage login details in one place** : Connection settings are maintained in the Admin menu.
- **Develop your own workflow framework** : A subdirectory in the DAG code repository contains a framework of operators that are 
  reused between DAGs.
- **Sense when to start a task** : The processing of dimensions and facts have external task sensors which wait until all processing
  of external DAGs have finished up to the required day. 
- **Specify configuration details once** : The place where SQL templates are is configured as an Airflow Variable and looked up 
  as a global parameter when the DAG is instantiated.

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
    truncate a non-existing table. An alternative is to follow a different path in the DAG that uses DELETE FROM on the 
    master table instead.

Issues
------

- There is currently an issue with *max_active_runs*, which only respects the setting in the first run.
  When backfill is run or tasks get cleared to be rerun, the setting is not respected:

  `https://issues.apache.org/jira/browse/AIRFLOW-137 <https://issues.apache.org/jira/browse/AIRFLOW-137>`_

- What is not demonstrated is a better strategy to process a large backfill if the desired 
  regular schedule is 1 day. 2 years of data leads to 700+ days and thus 700+ runs. This will eventually consume
  a lot of time, because the scheduler is run with a particular interval, jobs need to start, etc. Usually source 
  systems can handle larger date windows at week or month level. More about that in the other examples.
- When pooling is active, scheduling takes a lot more time. Even when the pool is 10 and the number
  of instances 7, it takes longer for the instances to actually run

