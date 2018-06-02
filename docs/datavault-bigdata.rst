Data Vault 3
============

.. important::

    This example is work in progress...

This example builds on the previous examples and changes some of the pre-processing that took place.
In conversations with others I extracted some important principles out of data warehousing
and integrated that with what modern technology offers us as reliability and technology.

The Datavault 2.0 book contains a picture that displays how you'd extract data from a source system,
add hashes (based on business keys) on that and then move it to a staging area. The datavault 2 example
was based on that (and left sort of open where the hash key generation should take place). In the example
it was chosen to become a 'join' in the source system on the source tables.

My conclusion is that it is impossible for each OLTP source system to derive business keys for foreign
relationships without performing these joins in the source system or working with the OLTP specific 
primary keys in the next step thereafter to associate the business key present in other tables
for link tables.

If you have:

- an "actor (actor_id, first_name, last_name)", where (first_name, last_name) is the business key.
- a "film (film_id, title, release_year, ...) table, where (title, release_year) could be the business key
- a link table in the source, which associates actors with films using (actor_id, film_id)

Then:

- actor would become a hub
- film would become a hub
- film_actor would describe the relationship between the business objects, so would become a link.

According to the picture in the DV 2.0 book, everything can be loaded in parallel, but this clearly demonstrates
that link tables in the source (or foreign keys) require a lookup somewhere (either in the source or in staging)
to satisfy the generation of the hash key for the link table in the data vault. The book does not make that very clear.

The same thing goes for some satellites, because some satellites are basically some columns moved to another table. An example of that is "customer_details", where some columns that would otherwise be in "customer" may have a different rate of change and for effiency purposes (or historying) were moved elsewhere.

In my view this is the biggest lack of clarity on the adoption of data vault, because as soon as all the hubs,
links and satellites are in place, the downstream processes are pretty clear.

The one thing that breaks in the theory from that perspective is that links and satellites cannot be loaded in parallel with hubs, but there is a dependency on the processing of hubs before links and satellites can be processed (at the very least). 

In this new example I'm leveraging some new ideas:

- Build up the DV 'incrementally' from a PSA in cloud storage. The entire DV however can be regenerated from cloud storage by attributing more resources.
- Use big data technologies to resolve the business key generation for link and satellite tables. The idea is that the output of other systems as we receive them is "pure" in the PSA on cloud storage (like a data lake) and that any decision (including the choice of a business key) is a relevant design decision that we must allow flexibility of changing in the future. What we maintain from there is a system where we extract data how it really was without 'enrichment' in any way, so a true bunch of 'facts-as-they-were'; any processes downstream
from that, including the choice of a business key are changeable, so we must allow for a process where the regeneration can happen. 


Principles
----------

This section lists some extracted principles that I think are extremely important to build any kind of
data warehouse. They are based on perceptions how some ODS's and Kimball systems were developed and how
the specific procedures added complexity or rigidity into the process.

1 Extract source data and keep it historied in a PSA, forever, on cloud storage. Cloud storage provides 11 "9's" of durability (1 in 10.000 documents is lost in 1 million years). No database backup scheme or cluster backup scheme can compete with that.
2 With a PSA, the entire data vault can be reconstructed, or parts of that. This is useful when busines keys are poorly chosen for example or you wish to change the hashing algorithm.
3 Do not combine data up until the very last moment: think about processing data as having separate lanes of traffic in your data warehouse. Where you allow the lanes to cross and everything downstream of that becomes the complexity you have to deal with. Really make a serious attempt to combine data only in your presentation layer and not right from the start of processing. The data vault allows you to do this, because the data vault is an attempt to label the source tables with regular business concepts; the keys are not required to correlate and you can load data in parallel in the data vault without them actually 'linking up'. You can take care of the 'linking up' later by attaching another link table that links the same hub together.
4 Don't do everything in a single query, but 'stage' and process your data in layers where each layer has a specific responsibility. ODS's and many other data warehouses fail over time because they depend on a (then) fixed set of source systems and then combine 'stuff' to produce value for the business early in the process by combining staging or fact tables early in the process. Delay that until the very end.
5 Introduce more abstraction layers where necessary: some source systems are really poorly designed. Data vault will not allow you to transform some OLTP design into a sensible business data model in a single step; the OLTP design bleeds over into the raw data vault. Take that into account and think about introducing another abstraction layer where the sources are fully dissociated from the 'business design' of the data warehouse.
6 The source OLTP systems may have time windows where it is unacceptable to put additional load on the system. 
If a data warehouse has to be reloaded, we cannot always count on the source system to give us the volume of data we want or at the frequency we want it. For that reason, cloud storage can be a very nice alternative
to look at historical representations of data.

