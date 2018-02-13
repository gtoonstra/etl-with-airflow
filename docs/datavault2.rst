Data Vault 2
============

.. important::

    This example is work in progress...

This is probably the final and most elaborate example of how to use ETL with Apache Airflow.
As part of this exercise, let's build a data warehouse on Google BigQuery with a DataVault
built on top of Hive. (Potentially, this example requires quite a lot of memory).
We're going to start a postgres instance that contains the airflow database and another 
database for the adventureworks database created by Microsoft. We'll use a Postgres port
of that.

The data will be loaded into a Hive instance from there and in Hive we'll set up the Data Vault
structures. Optionally, if you have a Google account you'd like to try out, you can set up a 
connection later on and load some flat tables into BigQuery out of the Data Vault as a final 
part of this exercise. Alternatively, let's look into building a Kimball model out of it.

Note that similar to the Hive example, I'm using a special build of the puckel docker airflow
container that contains the jar files for Hadoop, HDFS and Hive.

.. important::

    The default login for "Hue", the interface for the Cloudera quickstart container running Hive 
    is cloudera/cloudera.

We are also going to attempt to output some CSV files that are to be imported into databook.
What is databook?  It's an opensource project I'm running that attempts to replicate what Airbnb
made in their "DataPortal" description. You can read more about databook here:

`Databook <https://github.com/gtoonstra/databook>`_

Finally, let's re-test all the work we did against the ETL principles that I wrote about to see
if all principles are covered and identify what are open topics to cover for a full-circle solution.

About Datavault
---------------

In the :doc:`/datavault` example, we explained some of the benefits of using a datavaulting methodology
to build your data warehouse and other rationales. Go there for some of the core reasons why data vaulting
is such a nice methodology to use in the middle.

This example uses some other techniques and attempts to implement all the best practices associated with
data vaulting. The "2.0" refers to some improvements that have been made since the first version of the 
methodology came out. One of the primary changes is the use of hashes as a means to improve the parallel
forward flow of the data going into the final information marts and intermediate processing.

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
In short: operations where you may lose information should be avoided.

The staging area is temporary and I'm assuming delta loads are possible from the source system because of
a cdc solution being in place. If delta loads cannot be implemented due to a lack of proper CDC, then 
a persistent staging area (PSA) should be set up before that and delta loads be generated from there.

There are some operations that we can execute to enrich the incoming information. In Data Vault 2.0, 
hashing was added as a means to improve performance.

Our staging approach for all tables in the adventureworks dataset will be:

1. Truncate staging table
2. (optional) disable indexes. As we use Hive, this is not relevant, there are no indexes set.
3. Bulk Read source data in order. In this example we bulk read "everything" and then apply the rules, but in a real setting you'd have daily extracts for each staging table through a Change Data Capture system.
4. Compute and apply system values:
   * Load date
   * Record source
   * A sequence number
   * Hash for all business keys in a record. This is the record of the current table, but also business keys for all foreign keys into that table.
   * (optionally) a hash diff compiled from certain attributes through a controlled mechanism (never changes or gets reapplied)
5. Remove true duplicates
6. Insert records into staging table
7. (optional) rebuild indexes. Again, not relevant for this setup.

Given the above operations, we see that we should be able to apply a very common pattern to each
source table that we need to ingest. The general strategy is that in the staging area, every record
of interest for the current date partition gets loaded. In those records, the record gets a 
hash key assigned at the very least (even if that resolves to just a surrogate primary key) and
all foreign keys result in inner joins to other tables, so that we can generate the hash key for
the business keys in there. This is because the foreign keys will eventually convert to a link 
of some sort and having the hash key ready in staging allows us to parallellize the following stages
as well. It avoids potentially more expensive lookups further down the line, but unfortunately 
has a higher performance impact on the source system.

In the current implementation I'm using python code to apply the hashing, because it demonstrates that
hashing is possible even if the database engine doesn't implement your hash of interest.

.. important::
    The adventureworks database has some serious design flaws and doesn't expose a lot of useful 
    "natural" business keys that are so important in data vaulting. Because businesses have people that 
    talk about the data a lot, you should find a lot more references, identifiers and natural business keys
    in a true database setup that is actually used by and for people. The main staging setup is done in 
    "adventureworks_staging.py", which references SQL files in the 'sql' folder. In the SQL, you'll see the
    construction of the natural business keys at that stage.

There's an important remark to make about "pre-hashing" business keys in the staging area. It means that the 
decisions on what and how to hash are made in the staging area and there may be further issues downstream where
these design decisions can come into play. As the objective is to follow the methodology, we go along with
that and see where this takes us...

Another important note: notice how we don't specify what hive staging tables should look like. We're simply
specifying what we want to see in the Hive table. Because Hive is "Schema On Read", you can't enforce nullability
either, so there's no reason to set up a structured destination schema because nothing can be enforced about
it anyway. (which also means that malformed/corrupted files can have disastrous consequences, so it's extra
important to introduce integrity checks)

