Data Vault with Big Data processes
==================================

.. important::

    This example is work in progress. It is now loading the raw data vault, but I'm in the process 
    of validating this approach against the Data Vault 2.0 Modeling Standards. There are some deviations
    that should be documented. It also requires a better way to pass 'schema' from one processing
    stage to another.

This example builds on the previous examples yet again and changes the pre-processing stage.
In conversations with others I extracted some important principles out of data warehousing
and integrated that with what modern technology offers us as reliability and technology.

The Datavault 2.0 book contains a picture that displays how you'd extract data from a source system,
hashes its business keys and then moves it into the data vault. The datavault 2 example was based 
on that, but never really explained very well in the book where the hashing should take place. This is 
because the main example uses a huge flat file which is then decomposed into different datasets.
In my previous example I chose to hash all the keys in the source system query, which I think is wrong 
and not scalable.

To explain what I mean; if you have:

- an **actor** made up of (actor_id, first_name, last_name), where (first_name, last_name) are the chosen business key
- a **film** made up of (film_id, title, release_year, ...), where (title, release_year) is the chosen business key
- a **film_actor** table made up of (film_id, actor_id), which associates actors with films

Then:

- **actor** would become a hub
- **film** would become a hub
- **film_actor** describes the relationship between films and actors, so it would become a link table

**actor** and **film** can easily be loaded in parallel, but there is ambiguity how the business keys for the
film_actor link table should be generated. A join is needed to both actor and film to get the desired
fields to generate the business key. If you have a full dump of a source system, then you can perform
the join in staging and you can also load the link table in parallel to the hubs. If you have an incremental
load on any involved table, then you can no longer guarantee that the hub records are in staging, so you have 
to perform a lookup of some kind, which is to be avoided.

The same is the case for some satellite tables which are *extensions* to hub tables, for example a **customerdetails** table with its own records, potentially has versioned records by 'date' and where the primary key points to a customerid in the customer table. The business key is in **customer**, but it's not guaranteed that the **customer**
record is in staging when a record in **customerdetails** changes.

In my view the loading process is the biggest pain of the data vault, because as soon as all the hubs,
links and satellites are in place, the downstream processes are totally clear and there's no ambiguity.

So, this example changes some of the design decisions I made in previous examples:

- Do not use joins in source OLTP systems to resolve business keys (this also avoids making early business key decisions)
- For full replications of source data, the joins can be made in the data vault staging area instead
- For incremental loads, an index of primary key to hash key should be used to resolve the business key

This new example demonstrates how this would work and relies on a PSA as well. It is typically discouraged 
to use a PSA as a strategic mechanism for the data vault, but there are new trains of thought 
(because of BigData and data laking) where such opinions can change.

`Embrace your Persistent Staging Area <http://roelantvos.com/blog/?p=1890>` by Roelant Vos.

.. important::

    The implication of a PSA is that in theory, the data vault can be re-generated from scratch.
    How this impacts the data vault as a "System Of Record" and the associated auditability and traceability
    is unclear; perhaps from a legal perspective you won't be able to 'drop' the data vault like that.

The idea is that the PSA is never touched ever again, it is how the source system was at some point.
What you gain from this strategy is that the choice of business key, hashing algorithm, length of hash and
other such design decisions can be modified later. I.e. we defer design decisions to a later point in time
and maintain a pristine copy of source data without important design decisions embedded within them.

Principles
----------

This section lists some extracted principles that I think are extremely important to consider and they are valid if you build any kind of data warehouse. They are based on perceptions how some ODS's and Kimball systems evolved and how the specific procedures added complexity or rigidity into the system:

**Extract, verify and keep**: Extract source data and keep it historied in a PSA forever on practically infinite storage. Cloud storage provides eleven 9's of durability (1 in 10.000 documents is lost in 1 million years). This means that no other backup scheme can compete with this durability. Why not use that property?  (Just make sure that the extraction is 100% ok). Use UTF-8 as standard encoding, verify data types and precision output, etc. The extraction process is very generic, so once you have a generic process that really works, it is very easy to add more tables, which actually can become as simple as adding another line. (just work out the GDPR issues there :)

**Maintain data in lanes**: Do not combine data from different sources until the very last moment; delay this as far as possible. Think about processing data as having separate lanes of traffic in your data warehouse. The sooner data becomes integrated, the more processes downstream have to be modified when a source system changes, or become invalid for a longer period. Using views on terminal endpoints for each lane allows you to compare results individually and switch the implementation when the results are clear. The more you can keep data separated in lanes per source system, the less complex will be your data warehouse.

**Divide and conquer**: Don't perform all complicated logic in a single query; massage your data step by step, pivoting, filtering and working it until you can produce the end result with relatively simple joins. Add static data to define additional attributes where you may be missing some (never use mystical sequences of magic entity id's to filter data inside the query, i.e. don't hardcode id's). It's usually difficult to produce a useful analytical view  when you depart from the operational view, see the next principle!

**Work on abstraction layers**: Introduce abstraction layers to convert the OLTP design into an analytical structure. Data vault will not allow you to magically transform some OLTP design into a sensible business data model in a single step; the OLTP design always bleeds over into the raw data vault somehow. The OLTP / 3NF design is optimized for operational purposes, so there are important transformations to make there and this requires some thinking.


About the implementation
------------------------

The example builds on the datavault2 example a lot, but some steps were introduced between the source system and the DV processing by sending data to the PSA and integrating the PSA strategically in the entire process.

Airflow shows that a lot of the steps can be run fully in parallel:

.. image:: img/dv2-airflow.jpg

The general process becomes:

1) Extract each table in parallel fashion. The speed at which you can do this is dependent on the source OLTP system, your worker's disk I/O, etc. For each record, add a "load_dtm" field, which is the dtm of the dagrun in which the record was extracted (the "execution_dtm" attribute in airflow). Incremental extracts go straight to the PSA and also have a NEW/DELETED/UPDATED attribute added, full extracts go to a separate landing area for subsequent processing.
2) Using Apache Beam, process the full dumps in the landing area to identify the NEW, UPDATED or DELETED attribute for each record. An index is made up of a triplet of {primary key, row checksum, hash key}. This allows us to use the index to perform hash key lookups associated by primary key, but also verify if records have changed.
3) With another Apache Beam run for each table in the PSA, there are two important outputs: the data from the PSA that contains hash keys for each record and hash keys for all foreign keys as well as new triplets in the index for each table. Because of the dependency structure in ERD, the order of processing of each table in the PSA is important and not 100% parallel. The data output is separated into its own directory based on the LOAD_DTM (remember; we keep all data partitions separated by date interval, it is an important principle for easy reprocessing).
4) Create tables in Data Vault using EXTERNAL TABLE with LOCATION set to cloud storage. This is a zero copy operation, yet makes the files in each directory available as a table in Hive (plan the data output directory structure accordingly).
5) Apply the Hive staging tables to the raw data vault. This should be an idempotent process, but in the current implementation is additive. Using load_dtm as a partition, it is easy to drop and reload partitions however.
6) From there, apply further processing downstream until you have the datamarts.

I rendered the following picture from the "DataFlow" UI on google cloud, the process is actually runnable on local disk as well using the beam API (acceptable for this data size). The way things are currently implemented is that the dataflow pipelines are running serially. It should be possible to establish correct dependencies between them in a single pipeline, so that it flows fully in parallel, but that is slightly more complicated and could hit specific limits in the number of nodes (or node memory).

.. image:: img/dv2-dataflow.jpg

- It reads data from a csv file, which is then converted into json.
- Every row is then 'keyed' by applying the primary key, which generates a stream of data like (pk, record)
- The preprocessing stage selects the business key, calculates the hash key and calculates a checksum for the data.
- An 'index' is read from data processed prior to this dagrun. If there is no index, it creates an empty pcollection. An index is a triplet of (pk, hash, checksum)
- The data and the index are joined together on the primary key, this gives us for each primary key an index and/or data record.
- We can now identify data that didn't change (checksum of index == checksum of data), which gets discarded.
- We can also see what changed (there's an index and data and checksum != checksum).
- We can also see what's new (no index, but a data record)
- And what's deleted (there's an index, but no data)
- The index gets updated with new data records and written out as a new version of that index to be used as a source for the new dagrun.
- Tables with foreign keys do an additional lookup of the hash key of the foreign key by running the records through a 'CoGroupByKey' operation with the 'foreign index'. This introduces a dependency between hubs, so they cannot be processed in parallel. This means that the order of processing is becoming important in this step.


Full reprocessing run
---------------------

The full reprocessing run is remarkably similar. In fact, it's the same code as the incremental run, because we've already made sure that the input data is neatly organized in the PSA with a load_dtm and status per record.

The only difference is that instead of this "glob" pattern for the bucket location:

`<ROOT>/psa/<table_name>/YYYY/MM/DD/<table_name>*`

We use:

`<ROOT>/psa/<table_name>/*/*/*/<table_name>*`

The satellites can be loaded in a straight-forward way, but the hubs and links need a bit more attention. If we fully load from system A first and then B, it may appear as if all hub records were first seen in A when in reality, there are occasions where B was first. So that needs to be worked out with a different query for hubs and links.
