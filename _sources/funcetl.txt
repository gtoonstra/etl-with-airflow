Functional ETL
==============

The ETL example on postgres gives us some insights what's possible with airflow and to get acquainted
with the UI and task dependencies.

The Hive example showed how an interaction between an RDBMS and Hadoop/Hive could look like.

Both examples apply the Kimball data warehouse design methodology. The methodology has worked really well
over the 80's and 90's because businesses wouldn't change as fast and often. In a Kimball approach, there is 
a particular point in time where you make decisions about design (data model structure) and rules applied to
data (business rules) that are valid at that point in time, but may change in the future. What you end up with
is a data warehouse that is set up according to the design at that point in time, but may be difficult to change
as your business progresses (or rather expensive).

In Kimball you'd also chronologically accumulate your data from a staging area, which is usually
a volatile staging area. The new data "of the day" gets loaded into the dimensions and facts and
from there, it's part of the data warehouse (under the restrictions of the above "design moment in time").
Because it's incremental like that, reprocessing your data warehouse to reflect other incantations of
reality becomes very difficult.

In the Hive example I worked around that by regenerating the DWH from scratch every day, which allows you
to change destination structures and business rules that get applied to them, but this may be very costly to 
do over time. 

The following URL points to a very interesting article that aims to remove chronological data dependencies and
attempts to "isolate" your entire data pipeline into "intervals" that are individually reprocessable. Please take
some time to read it and understand the implications:

    https://medium.com/@maximebeauchemin/functional-data-engineering-a-modern-paradigm-for-batch-data-processing-2327ec32c42a

Objective
---------

What we're going to try to build in this example is a data warehouse that has the following properties:

* Immutable persistent staging area, capturing the state of the data at the point in time it was captured
* Work with table partitions and processing pipelines in a way that they can be individually reprocessed
* DAGs that change business rules and apply the correct rule based on the partitioning data
* Implement a data vault approach for source data; its design gives us more flexibility to change business rules

How to start 
------------

Run the following script on the console

::

    docker-compose -f docker-compose-func.yml up --abort-on-container-exit

To bring the entire structure down:

::

    docker-compose -f docker-compose-func.yml down
