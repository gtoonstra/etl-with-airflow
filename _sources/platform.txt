Building your own ETL platform
==============================

By now you've discovered that airflow is great as a programmable platform with a powerful scheduler in the middle
that decides when your tasks run. Let's dive a bit deeper into the architecture of airflow to be able to understand
the consequences of extending the platform for new capabilities and how to most effectively use them.

Understanding the airflow platform design
-----------------------------------------

When airflow runs tasks, they do not run in the same thread as the scheduler, but an entirely new python interpreter gets started
that is given some parameters to load the DAG of interest and then another parameter to indicate the task of interest, along with
some other parameters that belong to that task. 

This new python interpreter could run on the same machine as the scheduler, but it might as well run on a totally different worker
machine. If you follow through the examples, you'll also have noticed that the distribution of airflow across all those machines
is 100% the same. The scheduler machine does not run different software from the webserver or any of the workers; you'd typically
deploy the full airflow software distribution to any type of these machines, which can be good and bad, it certainly has the potential
to simplify the setup. The only thing that determines the role that each process plays in the grand scale of things is the command
that you use on each machine to start airflow with; `airflow scheduler`, `airflow webserver` or `airflow worker`. The workers are 
not started by users, but you allocate machines to a cluster through celery.

.. important::

    The webserver, scheduler and worker all run exactly the same software, but are started with different commands.

Understanding hooks and operators
---------------------------------

Hooks and operators are the key to understanding how airflow can be extended with new capabilities and to keep your DAGs clean and simple.
A DAG should be *readable* in the sense that it's a description of workflow. Whatever the underlying technical or business principles are that
you must follow, reading through a DAG should be like reading through a reading a business workflow document, describing what a particular
business process is trying to achieve.

A **hook** is an object that embodies a connection to a remote server, service or platform.

An **operator** is an object that embodies an operation utilizing one or more hooks, typically to transfer data between one hook and the other
or to send or receive data from that hook from/into the airflow platform, for example to _sense_ the state of that remote.

As an example, when you see *MySqlOperator*, it typically identifies an operator that executes some action on a single hook that interfaces with, 
in this case, a MySQL database. 

When you see *MySqlToMySqlOperator*, it typically identifies an operator that interfaces two systems together, through the airflow worker,
and transfers data between them. 

The default supplied operators in airflow are relatively simple. They embody some basic actions like data transfer. 

Do not take these operators as the prescribed way of doing things that absolutely has to be followed in order to be successful. 
Some users have used the operators as the basis for their own platform framework, but significantly enriched the behavior. One such example 
is a company using airflow, which archives every data entity ingested from external sources onto some storage solution, according to a 
pre-defined URL scheme. The standard operators and hooks implement and abstract this specific behavior, so the DAGs do not get polluted by any
of this additional processing. In a similar way you could add metric collection to operators or leave that in your DAGs, those are design choices.

Publish site-speific documentation
----------------------------------

After you finish building airflow, it's a good idea to build your own documentation site. The airflow site and this site are built using sphinx,
which works great for python projects. You can document a part about your specific use of airflow, agreements and principles that you
set up and include the documentation for each operator and hook that you develop as part of the platform. Release that documentation site 
as part of your continuous integration pipeline and the documentation site will always be up to date.


