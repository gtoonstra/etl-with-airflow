Data vault with DBT
===================

DBT is a very interesting project which I think automates a large number of important tasks.
Recently someone pointed me at a datavault plugin for dbt, which I think makes sense
to check out and see if I can rebuild the datavault2 bigdata example with a lot less
code using DBT.

The main plugin I'm going to use is dbtvault:

https://github.com/Datavault-UK/dbtvault/

Install dbt:

* `cd examples/datavault2-dbt-example`
* `python3 -m venv venv`
* `source venv/bin/activate`
* `pip install --upgrade pip setuptools wheel`
* `pip install dbt`
* `cd dv2`
* `dbt deps`

