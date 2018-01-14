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

How to start
------------

::

    docker-compose -f docker-compose-hive.yml up --abort-on-container-exit

This will download and create the docker containers to run everything. This is how you can clear the containers, so that you can run the install again after resolving any issues:

::

    docker-compose -f docker-compose-hive.yml down


The image that runs airflow needs to have beeline installed to be able to use Hive. I've created
an updated "puckel" image of airflow that does that, which is available here:

::

    https://github.com/gtoonstra/docker-airflow

This has been pushed to docker cloud as well, so when you run the script, that's what it pulls in.

How to run
----------

Run the "init_hive_example" dag just once to get the connections and variables set up.
You can see in that DAG what it requires. This is just to bootstrap the example.

Run the "staging_oltp" DAG and let it finish before you start the processing scripts. This 
is because there's currently no operator in the DAG that verifies the dependency of OLTP versus the
processing tasks. 

Finally, run the "process_hive_dwh" DAG when the staging_oltp is finished.

How it works
------------

The staging process gathers the new products and customers that appear over a certain time window.
Orders and order lines are not updated in this example, so these are always "new". Customers and products
may receive updates and these are managed by allocating them by their "change_dtm". All data is partitioned
per day. This results in a number of partitions per table in Hive.

The data warehouse is regenerated entirely from scratch using the partition data in the ingested OLTP structures.
This means the dimensions and facts are truncated and rebuilt on a daily basis.

In a straight-forward Kimball approach, you'd persist and maintain the dimensions and facts because they are too
expensive to regenerate. For smaller data warehouses though, you can use the multi-processing capabilities to achieve this.

Strategy
--------
The main strategy here is to parallellize the way how data is drawn from the database. 
What I've maintained in this example is a regular star-schema (Kimball like) as you'd 
see one in a regular data mart or DWH, but the dimensions are somewhat simplified and use 
a mix of SCD type 1 and type 2 dimensions. (SCD = Slowly Changing Dimension). Similar to the 
ETL example, the dimensions are processed first, then per fact you'd tie the data to the dimensions.

Typical Kimball DWH's accumulate data chronologically over time. It is uncommon to reprocess portions
of the DWH historically because of the complications that arise if other processing runs have 
run after a failure.

In this example therefore, the source data is kept and the entire DWH regenerated from scratch using the source data
in two simple operations.
