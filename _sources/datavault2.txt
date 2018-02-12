Data Vault 2
============

.. important::

    This example is work in progress...

This is probably the final and most elaborate example of how to use ETL with Apache Airflow.
As part of this exercise, let's build a data warehouse on Google BigQuery with a DataVault
built on top of Hive. So... this example may request a bit of memory from your machine.
We're going to start a postgres instance that contains the airflow database and another 
database for the adventureworks database (yeah, the one from Microsoft).

Then the data will be transferred to a Hive instance and from there, if you have an account
you'd like to try out, we'll transfer the facts + dimensions as a single large table 
to a BigQuery instance for further analysis.

Note that similar to the Hive example, I'm using a special build of the puckel docker airflow
container that contains the jar files for Hadoop, HDFS and Hive.

.. important::

    The default login for "Hue", the interface for the Cloudera quickstart container running Hive 
    is cloudera/cloudera.

We are also going to attempt to output some CSV files that are to be imported into databook.
What is databook?  It's an opensource project I'm running that attempts to replicate what Airbnb
made in their "DataPortal" description. You can read more about databook here:

`Databook <https://github.com/gtoonstra/databook>`

About Datavault
---------------

In the :doc:`/datavault` example, we explained some of the benefits of using a datavaulting methodology
to build your data warehouse and other rationales. Go there for some of the core reasons why data vaulting
is such a nice methodology to use in the middle.

This example uses some other techniques and attempts to implement all the best practices associated with
data vaulting. The "2.0" refers to some improvements that have been made since the first version of the 
methodology came out.

Overall flow
------------

This is the general flow to get data from the OLTP system into (eventually) the information mart. 
Here you can see how the Data Vault essentially fulfills the role of the Enterprise Data Warehouse
as described by Ralph Inmon, years ago.

.. image:: img/dataflow.jpeg

Staging flow
------------

Staging is the process where you pick up data from a source system and load it into a 'staging' area
maintaining as much as possible of the source data as possible. The "hard business rules" may be executed,
for example changing the data type of an item from a string into a datetime, but you should avoid 
splitting, combining or otherwise modifying the incoming data elements and leave that to a following step.
I.e... operations where you may lose information should be avoided.

There are some operations that we can execute to enrich the incoming information. In Data Vault 2.0, 
hashing was added as a means to improve performance.

Our staging approach for all tables in the adventureworks dataset will be:

1. Truncate staging table
2. (optional) disable indexes. As we use Hive, this is not important for us.
3. Bulk Read source data in order. In this example we bulk read "everything" and then apply the rules, but in a real setting you'd have daily extracts for each staging table through a Change Data Capture system.
4. Compute and apply system values:
   * Load date
   * Record source
   * A sequence number
   * Hash based on the business key identifying the record
   * (optionally) a hash diff compiled from certain attributes through a controlled mechanism (never changes or gets reapplied)
5. Remove true duplicates
6. Insert records into staging table
7. (optional) rebuild indexes

Given the above operations, we see that we should be able to apply a very common pattern to each
source table that we need to ingest, which suggests we should be able to create parameterizable operators
and use a set of functions with table names, strings and reflection to move forward. 

.. important::
    This technique shouldn't work too bad for delta loads where the number of records is rather limited.
    If you can only work with full loads from a source system, you may have to set up a Persistent Staging Area (PSA),
    which you use to identify the new, changed and deleted records to generate your own delta records and then
    run it through the above pipeline.

