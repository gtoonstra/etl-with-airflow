Gotcha's
========

It's always a good idea to point out gotcha's, so you don't have to ask in forums / online to search
for these issues when they pop up. Most of theses are consequential issues that cause situations where
the system behaves differently than what you expect.

**Start_date and interval confusion**: The *start_date* specifies the first date and time for which 
you want to have data in a database. Airflow will run a job at *start_date + interval*, so after the 
interval has passed (because that's when data becomes available). You can read more about the rationale
in the `Airflow FAQ <https://airflow.incubator.apache.org/faq.html/>`_

**Don't forget to start a scheduler**: When you use airflow for the first time, the tutorial makes 
you run a webserver, but doesn't specify how to start a scheduler. If you play around with the web UI,
specifically the tasks interface, you'll notice that nothing gets rescheduled to be re-run. 
This is because you should run both a webserver and a scheduler. 

You can start a scheduler on the shell through:
::

    > airflow scheduler  

**Starting your first DAG development**: When you start developing your first DAG you'll probably rename 
a couple of task instances in the process. When a DAG was run for a particular date, the instances are actually
recorded in the database against the old task instance name. The UI will only ever show the DAG diagram for
the tasks as they are currently known, so if you renamed things, they won't be there. If you had 2 tasks that were
already run and you renamed both of them, the UI will be empty. You can trigger a full DAG rerun through the 
command line only in that case to get your UI back in order:

::

     > airflow backfill -s YYYY-MM-DD -e YYYY-MM-DD <dag_id>


**Don't change start_date + interval**: When a DAG has been run, the scheduler database contains instances of
the run of that DAG. If you change the start_date or the interval and redeploy it, the scheduler may get confused
because the intervals are different or the start_date is way back. The best way to deal with this is to change
the version of the DAG as soon as you change the start_date or interval, i.e. *my_dag_v1* and *my_dag_v1*. This way,
historical information is also kept about the old version.

**Refresh DAG in development**: The webserver loads DAGs into the interpreter and doesn't continuously update them
or know when they changed. The scheduler however instantiates the DAGs continuously if they are needed. In the UI
you can therefore see outdated versions when you check out the code or see the execution diagram. This is why there's
a *refresh* button on the main DAG screen, which is where you can reload the DAGs manually.

**Additional info**: Check out the `Project page <https://airflow.incubator.apache.org/project.html>`_ 
for additional info (see the **Resources & links** section at the bottom).

