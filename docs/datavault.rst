Data vault
==========

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

The datavault example demonstrates the use of the datavault methodology of data warehousing using airflow
as the ETL processing platform.

Methodology
-----------

The Data Vault modeling approach has various benefits:

* Simple data ingestion process
* Design of the data query model (star schema?) no longer fixed forever and can be modified
* Auditability for various regulatory requirements
* Can add or switch data sources without disrupting existing query schema
* Reduces complexity in ETL at the cost of slightly more code
* Simplifies design stage because it can be changed
* Reorganizes data model from the source into a more flexible intermediate data model

Data Vault uses a more flexible representation of the data, which is organized in three main elements:

* Hubs: These contain the main business entities: customers, products, orders, invoices, shipments.
* Links: These provide the relationships between hubs: e.g. a shipment made on behalf of an order of a customer
* Satellites: These are versioned sub-tables providing the details about the relationship or hub, for example:
    * customer details 
    * order details
    * product details, quantity, price, vat and other details in a product shipment

For more information on data vault modeling, see these links:

* https://en.wikipedia.org/wiki/Data_vault_modeling
* http://tdan.com/data-vault-series-1-data-vault-overview/5054
* https://www.youtube.com/channel/UCFN-i5nthZgdR0xj3UYYqVw

How to start the example
------------------------

Run the following script on the console

::

    docker-compose -f docker-compose-dv.yml up --abort-on-container-exit

To bring the entire structure down:

::

    docker-compose -f docker-compose-dv.yml down

Limitations
-----------

.. important::

    There are limitations and things missing in this implementation

* Multiple records per time window are not managed. This implementation can only process one change record per day
* In order to correctly process entity changes, you need either a mature Change Data Capture solution that stamps the date/time of the change and shows the updates/inserts or the source system has to version them in the application. If you do not use CDC and records have been updated, you cannot "date" those records at the time of the change and the system must make assumptions when the change really took place.
* This example uses the DataVault 1.0 methodology that does not depend on hash keys.
* The resulting star schema is rebuilt from scratch daily in this implementation. You probably want to incrementally build that, but it shows what is possible with the data vault.
* Data must be staged in chronological order and not be rerun. You cannot reload existing data into the data vault or run yesterday's data over today's data.
