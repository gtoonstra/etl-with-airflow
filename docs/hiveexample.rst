Hive example
============

.. important::

    !This example is in progress!

The ETL example demonstrates how airflow can be applied for straightforward
database interactions. One of the powers of airflow is the orchestration of 
bigdata jobs, where the processing is offloaded from a limited cluster of 
workers onto a larger platform like Hadoop (or one of its implementors). 

This example uses exactly the same dataset as the regular ETL example, but all
data is staged into Hadoop, loaded into Hive and then post-processed using
parallel Hive queries. This provides insight in how BigData DWH processing is 
different from normal database processing and it gives some insight into the 
use of the Hive hooks and operators that airflow offers.

For successful BigData processing, you typically try to process everything in
parallel as much as possible. The DAGs are therefore larger and show parallel
paths of execution for the different dimensions and facts.

The code is located (as usual) in the repository indicated before under the "hive-example"
directory. What is supplied is a docker compose script (docker-compose-hive.yml),
which starts a docker container, installs client hadoop+hive into airflow and other
things to make it work. You may need a beefy machine with 32GB to get things to run though.

If that doesn't work, you can always use the source code to connect to a development
instance of hive somewhere.

How to run it
-------------

::

    docker-compose -f docker-compose-hive.yml up --abort-on-container-exit

This will download and create the docker containers to run everything. This is how you can clear the containers, so that you can run the install again after resolving any issues:

::

    docker-compose -f docker-compose-hive.yml down


Then run the "init_hive_example" dag once to get the connections and variables set up.

Strategy and issues
-------------------
The main strategy here is to parallellize the way how data is drawn from the database. 
What I've maintained in this example is a regular star-schema (Kimball like) as you'd 
see one in a regular data mart or DWH, but the dimensions are somewhat simplified and use 
a mix of SCD type 1 and type 2 dimensions. (SCD = Slowly Changing Dimension). Similar to the 
ETL example, the dimensions are processed first, then per fact you'd tie the data to the dimensions.

