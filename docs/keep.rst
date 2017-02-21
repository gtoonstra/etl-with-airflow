Interval based vs. time based
-----------------------------

As airflow is interval based, not simply time based and dependent on the day when you execute the DAG, this allows for a very consistent method of 
reprocessing historical data. You can change the processing rules at the expense of a full reprocessing run and decide if you want to reload
data on a weekly, monthly or yearly basis.

Since airflow 1.8, you can now rely on some new macros to identify a specific processing interval: 

- _execution_date_
- _prev_execution_date_ and 
- _next_execution_date_

So you can use _daily_ DAGs that perform regular day-to-day processing and switch to manually activated weekly, monthly or yearly DAGs when you want to 
more agressively reprocess an entire dataset.
