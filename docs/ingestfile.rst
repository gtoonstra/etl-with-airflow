Ingesting files
===============

It's helpful to have an audit record of the data that you ingested from external systems. These external systems
can already be in a file format (FTP), an HTTP/SOAP/API connection with json or xml output, or perhaps even
by connecting to an external database directly.

Storing the data that you ingested this way is helpful for troubleshooting. If you ingest the data and then immediately
attempt to store that in an on-premises database, you need to rely on the workflow logs to be able to figure out what
happened if a problem occurred. With a record of the file that you attempted to ingest, you achieve two things:

* You can easily debug why some source data could not be ingested by a target system.
* You can easily rerun parts of your workflow that start with picking up the file from an archive location.
* You can historically reprocess all data that you picked up from days, weeks and months before without having
  to go back to this source system. This is very important, because source systems do not always keep this archive,
  may not support parametrization to do this effectively (for example, only gives you data from 'yesterday') and other reasons.

So, establishing that keeping a record of all ingested data is a good thing, let's go about implementing this in airflow.
FYI, I'm borrowing these ideas from a presentation given by IndustryDive, available from the `Airflow links <https://cwiki.apache.org/confluence/display/AIRFLOW/Airflow+Links>`_ page.

Rather than hand-crafting file locations or passing files around, start with developing a predictable method for locating data files.
Tasks that ingest data dump data files in those locations and tasks that read data dynamically determine these locations to read from.

The example that I devised shows the development of two types of operators. The **FileToPredictableLocationOperator** shows you how to 
develop an operator that dumps a file to a predictable location. The **PredictableLocationToFinalLocationOperator** is the operator that 
consumes from this location and processes the file to its final location.

Assuming that you still have the etl-with-airflow project cloned somewhere, I left a simple bash script to create some empty files
in a particular sample structure so that you can see how this is supposed to work in general. Here's how to do that:

.. code-block:: bash

    $ cd file-ingest
    $ ./create_files.sh
    $ cp -R * $AIRFLOW_HOME/dags

Now simply run the airflow webserver and the airflow scheduler as before, activate the **file_ingest** dag and it should start processing the
files you just created. Look into *file_ingest.py* and *acme/operators/file_operators.py* to see how the example works.

Extending from the example
--------------------------

The above example uses a local filesystem to reduce the dependency on more complex connections and external environments like AWS, Google Cloud or 
whatever storage you may have available. This is to keep the example simple. In real world scenario's, you'd probably write a bunch of operators to
operate this way. The more incremental your process is, the more 

In the source code under *contrib*, you can see a number of example operators that move data from one system to another. The closest example is 
a **FileToGoogleCloudStorageOperator** in *file_to_gcs.py*. What you need to do yourself is determine for which these intermediate predictable 
"archive" locations apply.

.. important::

    **Remember:** An operator in airflow moves data from A to B. In that sense, it's just an abstraction
    component over two (types of) hooks that need to cooperate together and achieve something in a sensible way.
    Operators are a great way to introduce these design choices and introduce more generic behavior at almost zero cost.
    Beyond just moving data from A to B, your platform engineers should concern themselves about how to abstract these
    behaviors from other engineers who otherwise make arbitrary choices.

Also notice how many operators derive from the BaseOperator. 
