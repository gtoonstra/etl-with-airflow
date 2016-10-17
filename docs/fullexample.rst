Full example
============

To demonstrate how the ETL principles come together with airflow, let's walk through a simple, full
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

Set up Postgres connection
--------------------------

We need to declare this postgres connection in airflow. Go to the connections screen in the UI (through Admin)
and edit the default. Make sure to keep the connection string ID as *postgres_default*. You can check if this
connection is working for you in the *Ad-hoc query* section of the *Data Profiling* menu and select the same
connection string from there and doing a select on the order_info table:

::

    SELECT * FROM order_info;

Drop stuff into airflow
-----------------------

In a real setup you'd use continuous integration to update DAG's and dependencies in airflow after changes, 
but now we're going to drop in the lot straight into the DAG directory for simplicity.

.. code-block:: bash

    $ cd full-example/dags
    $ cp -R * $AIRFLOW_HOME/dags
    $ mkdir $AIRFLOW_HOME/sql
    $ cd full-example/sql
    $ cp order_copy.sql $AIRFLOW_HOME/sql
    $ cp orderline_copy.sql $AIRFLOW_HOME/sql

Run it
------

In the airflow UI, refresh the main DAG UI and the new dag should be listed (full-example). Probably the scheduler
has already started executing the DAG, so go into the detail view for the DAG to see what the result was.

