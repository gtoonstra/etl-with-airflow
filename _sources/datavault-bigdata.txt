Data Vault with Big Data processes
==================================

.. important::

    This example is work in progress. The previous example had many disadvantages and
    after advanced insights, I've started reworking the example to become easier to manage.

This example builds on the previous examples yet again and changes the pre-processing stage.

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

So from the previous example, I've now come to the conclusion that data extraction should perform a "clean" 
extract of the source data without introducing data vault design decisions. You could add two simple 
fields to the data extract (extraction_dtm and status) for each record, which will help you later.
The extraction_dtm is the time when the batch ran, the status is an indicator if the record is NEW,
UPDATED or DELETED.

In the current example, I'm using advanced SQL functions (2016) to extract nested records. The extract is
actually done in JSON, which is handled perfectly in python. Because I'm assuming incremental extracts
for the majority (only extract what changed for the day), this shouldn't take that long.

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
other such design decisions *can* be modified later, although it should never be the purpose of the PSA, the
purpose is to support the development and deal with significant design decision pains in the startup phase of 
the DWH. The PSA allows us to defer design decisions to a later point in time and maintain a pristine copy 
of source data without important design decisions embedded in them (we don't have pre-generated business keys
from the source extract, we don't have hashes based on pre-identified hashing algorithms or sizes).

Principles
----------

This section lists some extracted principles that I think are extremely important to consider and they are valid if you build any kind of data warehouse. They are based on perceptions how some ODS's and Kimball systems evolved and how the specific procedures added complexity or rigidity into the system:

**Extract, verify and keep**: Extract source data and keep it historied in a PSA forever on practically infinite storage. Cloud storage provides eleven 9's of durability (1 in 10.000 documents is lost in 1 million years). This means that no other backup scheme can compete with this durability. Why not use that property?  (Just make sure that the extraction is ok). Use UTF-8 as standard encoding, verify data types and precision output, etc. The extraction process is very generic, so once you have a generic process that really works, it is very easy to add more tables, which actually can become as simple as adding another line.

**Maintain data in lanes**: Do not combine data from different sources until the very last moment; delay this as far ahead as possible. Think about processing data as having separate lanes of traffic in your data warehouse. The sooner data becomes integrated, the more processes downstream have to be modified when a source system changes, or when they get replaced. Using views on terminal endpoints for each lane allows you to compare results individually and switch the implementation when the results are clear. The more you can keep data separated in lanes per source system, the less complex the management and future development of your dwh will be.

**Divide and conquer**: Don't perform all complicated logic in a single query; massage your data step by step, pivoting, filtering, PITting and working it until you can produce the end result with simple joins. Add static data to define additional attributes where you may be missing some (never use mystical sequences of magic entity id's to filter data inside the query, i.e. don't hardcode identifiers). It's usually difficult to produce a useful analytical view when you depart from the source operational view, see the next principle!

**Work on abstraction layers**: Introduce abstraction layers to convert the OLTP design into an analytical structure. Data vault will not allow you to magically transform some OLTP design into a sensible business data model in a single step; the OLTP design always bleeds over into the raw data vault somehow. The OLTP / 3NF design is optimized for operational purposes, so there are important transformations to make there and this requires some thinking.

**Extract entities, not tables**: The previous examples all worked with tables, which means that you're extracting artifacts from some 3NF design that has its own quirks and issues and propagate all those design choices towards other endpoints that have completely different needs. For this reason I started to use more advanced "json extraction methods", which allows me to nest data from queries and extract 'entities' rather than table records. If you can't do that, you should consider merging records into entities elsewhere, but it will definitely be harder.

Entities, not records
---------------------
Entities can be compared to documents in NoSQL systems. Although it's also a challenge to analytically query over those in its own format, there are huge advantages to thinking in terms of entities:

- Instead of multiple file types, you have one file type
- There is no need to combine files to see the data in closer context
- Each entity is an event or object in a business process (invoice, customer, transaction, etc.)
- It saves a lot of work.
- Much less code, much less repetition and lower complexity.

About the implementation
------------------------

The example builds on the datavault2 example a lot, but some steps were introduced between the source system and the DV processing by sending data to the PSA and integrating the PSA strategically in the entire process.

Airflow shows that a lot of the steps can be run fully in parallel:

.. image:: img/dv2-airflow.jpg

The general process becomes:

1) Extract each entity in parallel fashion. The speed at which you can do this is dependent on the source OLTP system, your worker's disk I/O, etc. For each entity, add a "load_dtm" field, which is the dtm of the dagrun in which the entity was extracted (the "execution_dtm" attribute in airflow) and a 'status' field to indicate if it's NEW, UPDATED or DELETED. Incremental extracts go straight to the PSA and also have a NEW/DELETED/UPDATED attribute added, full extracts of a table go to a staging area first for other processing.
2) Using Apache Beam, process the full dumps in the staging area to identify the NEW, UPDATED or DELETED attribute for each record in a full dump. An index made up of a triplet of {primary key, row checksum, hash key} is used to filter out unchanged entities, so we only process entities that have changed. The output of this process brings the full dump entities to the PSA as well.
3) With another Apache Beam, run for all entities in the PSA on the given processing dtm. There are two main outputs: entity data split into the raw data vault model and new records for an updated index for each entity. Because of dependencies between entities, the order of processing of each entity is important and therefore not 100% parallel (we must make sure to work with the latest index). For each data file produced that goes into data vault staging, it is organized in its own directory by LOAD_DTM. The output here is written in the Avro file format, so it has its own schema. This is the stage where we are making data vault design decisions (choice of hash key, algorithm, hash size, splitting up the data from entities, looking up related entities from entity indexes, etc)
4) For each output data file, create a staging table in Data Vault using EXTERNAL TABLE with LOCATION set to cloud storage, again using the same avro schema declared earlier. This ensures consistency and writing the schema once. Loading into Hive like this is a zero copy operation.
5) Apply the data from the Hive staging tables to the raw data vault. The staging data contains data for hubs and satellites, links and satellites and sometimes only for links without satellites. You now have an updated raw vault.
6) From there, continue processing the Business Vault.
7) From there, perform further processing towards data marts in a star schema.

I rendered the following picture from the "DataFlow" UI on google cloud, the process is actually runnable on local disk as well using the beam API (acceptable for this data size). The way things are currently implemented is that the dataflow pipelines are running serially. It should be possible to establish correct dependencies between them in a single pipeline, so that it flows fully in parallel, but that is slightly more complicated and could hit specific limits in the number of nodes (or node memory).

<< outdated >>

