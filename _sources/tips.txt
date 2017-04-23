Tips
====

This section gives you some tips for handling specific cases in the use of airflow

Long running processes
----------------------

The main ETL example uses a workflow with only short-running tasks. Extracting
data and processing that should only take up to 5-10 minutes max at the most.

There are some cases where you have long running jobs that take one to several hours.
You'd typically check in one of two ways whether this job has completed:

* Check on an interface of some kind for job completion
* Check for availability of the output of that job

For example, if you run a spark hadoop job that processes item-to-item recommendations and
dumps the output into a data file on S3, you'd start the spark job in one task and keep
checking for the availability of that file on S3 in another.

Quick deployment
----------------

Many organizations require a proof of concept to demonstrate the suitability of a software
product to other engineers. In the root of this repository on github, you'll find a file
called _dockercompose-LocalExecutor.yml_. This file is used to demonstrate the ETL example
and you should be able to edit and reuse that concept file to build your own PoC or 
simple deployment.

Other uses for the docker deployment are for training or local development purposes.

In the ETL example, there are files for:

* Setting up a sample database. You can override this with other databases of your choosing,
  or rewire that into another docker deployment for mssql (also on linux now) or mysql.
* A dag that sets up connections after you recreate your containers, which you need to run only once.
* Some dags that demonstrate the ETL example, which you can replace by your own 
  functional dags of your choosing.

Connection administration
-------------------------

Airflow stores connection details in its own database, where the password and extra settings can be
encrypted. For development setups, you may want to reinstall frequently to keep your environment clean
or upgrade to different package versions for different reasons.

The ETL example contains a DAG that you need to run only once that does this. You can change the source
where this DAG gets the connection information from and then, after recreating the development environment,
run that DAG once to import all the connection details from a remote system or a local file for example.

