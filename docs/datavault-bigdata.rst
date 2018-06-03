Data Vault with Big Data processes
==================================

.. important::

    This example is work in progress. It is now staging the data into the staging area of the DV,
    the load into the raw data vault is being worked on.

This example builds on the previous examples yet again and changes some of the pre-processing.
In conversations with others I extracted some important principles out of data warehousing
and integrated that with what modern technology offers us as reliability and technology.

The Datavault 2.0 book contains a picture that displays how you'd extract data from a source system,
hashes its business keys and then moves it into the data vault. The datavault 2 example was based 
on that, but never really explained very well in the book where the hashing should take place. 
In my example I chose to hash all the keys in the source system query, which I eventually think is wrong.

If you have:

- an "actor (actor_id, first_name, last_name)", where (first_name, last_name) could be the business key.
- a "film (film_id, title, release_year, ...) table, where (title, release_year) could be the business key
- a link table in the source, which associates actors with films using (actor_id, film_id)

Then:

- actor would become a hub
- film would become a hub
- film_actor would describe the relationship between the business objects, so would become a link table.

Actor and Film can certainly be loaded in parallel, but there is ambiguity how the business keys for the
film_actor link table should be generated. A join is needed to both actor and film to get the desired
fields to generate the business key.

The same is the case for some satellite tables, when they have a foreign key to a hub. An example could be a 
customerdetails table, which could be versioned and where the primary key points to a customerid in the customer
table, but the 'customer-tag' field is the real business key.

In my view this is the biggest lack of clarity on the adoption of data vault, because as soon as all the hubs,
links and satellites are in place, the downstream processes are pretty clear.

Thus, for this example I'm establishing the following new principles:

- Joins in source OLTP system should not be used to resolve business keys
- For full replications of source data, the joins can be made in the data vault staging area instead
- For incremental loads, an index of primary key to hash key should be used to resolve the business key

This new example demonstrates that approaches and uses a PSA as well. It is discouraged to use a PSA
as a strategic mechanism for the data vault, but there are new trains of thought (because of BigData and 
data laking) where these principles could change:

`Embrace your Persistent Staging Area <http://roelantvos.com/blog/?p=1890>` by Roelant Vos.

So the general process becomes:

- Dump your tables in full or incrementally `verbatim` into your data lake. Only worry about adding a "load_dtm" column to make things easier. Dump them in time-based structure.
- Use Apache Beam (Google Cloud Dataflow, Apache Spark, etc) to generate business keys columns, source columns and even determine if a record is new, updated or deleted.
- Load the files into Data Vault as an EXTERNAL TABLE with LOCATION set to cloud storage.
- Transfer records from these tables into the raw data vault.
- Post process the data vault as usual.

The idea is that the PSA is never touched ever again, it is how the source system was at some point.
The Data Vault becomes a reflection of that status, but the design decision around your business keys and
the hashing algorithm can be modified later.

Principles
----------

This section lists some extracted principles that I think are extremely important to consider to build any kind of
data warehouse. They are based on perceptions how some ODS's and Kimball systems were developed and how
the specific procedures added complexity or rigidity into the process.

**Extract, verify and keep**: Extract source data and keep it historied in a PSA forever on practically infinite storage. Cloud storage provides eleven 9's of durability (1 in 10.000 documents is lost in 1 million years). This means that no other backup scheme can compete with this durability. Why not use that property?  (Just make sure that the extraction is 100% ok): Use UTF-8 as a standard, verify data types and precision output, etc. The extraction process is very generic, so once you have something that really works, it is very easy to add more tables.
**Maintain data in lanes**: Do not combine data from multiple sources until the very last moment; delay this as far as possible. Think about processing data as having separate lanes of traffic in your data warehouse. The sooner data becomes integrated, the more processes downstream have to be modified when a source system changes. Using views on terminal endpoints for each lane allows you to compare results individually and switch the implementation when the results are clear. The more you can keep data separated by source system, the less complex your data warehouse.
**Divide and conquer**: Don't perform all complicated logic in a single query; massage your data step by step, pivoting, filtering and working it until you can produce the end result with relatively simple joins. Add static data from external sources to add additional attributes where you may be missing it (never use mystical sequences of 
magic entity id's to filter your data). It's difficult to produce a usable analytical view of the business when you
depart from the operational view, see the next principle!
**Work on abstraction layers**: Introduce abstraction layers to convert the OLTP design into an analytical structure. Data vault will not allow you to magically transform some OLTP design into a sensible business data model in a single step; the OLTP design always bleeds over into the raw data vault. Take that into account and think about making gradual conversions from an operational view into a business (analytical) view.

