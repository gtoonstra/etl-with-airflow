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
    
**Additional info**: Check out the `Project page <https://airflow.incubator.apache.org/project.html>`_ 
for additional info (see the **Resources & links** section at the bottom).

 
