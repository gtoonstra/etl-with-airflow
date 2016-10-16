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
    

