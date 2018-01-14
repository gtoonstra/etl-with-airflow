ETL principles
==============

Before we start diving into airflow and solving problems using specific tools,
let's collect and analyze important ETL best practices and gain a better understanding
of those principles, why they are needed and what they solve for you in the long run.

The best practices make a lot more sense when you work for a fairly large organization that
has a large number of data sources, calculation processes, maybe a bit of data science and
maybe even big data. The best practices will also remind you how ad-hoc scheduling and 
'solving it quick to get going' approaches eventually create a tangled mess of data problems,
inconsistencies and downstream issues that are difficult to analyze and solve.

The nice thing about airflow is that it is designed around the following best practices
already, so implementing your new workflows is relatively easy. The reason that I started this
site is because I want to help people get better results with their new setup by indicating
usage patterns in DAGs and how to solve specific problems.

Airflow follows a nice, meditated philosophy on how ETL jobs should be structured. This philosophy
enables airflow to parallelize jobs, schedule them appropriately with dependencies and historically 
reprocess data when needed. This philosophy is rooted in a couple of simple principles:

**Load data incrementally**:  When a table or dataset is small, you can afford to extract it as a whole and 
write it to the destination. As an organization grows however, you’ll need to extract data incrementally 
at regular intervals and only load data for an hour, day, week, etc. Airflow makes it very easy to schedule 
jobs such that they process specific intervals with job parameters that allow you select data.

**Process historic data**:  There are cases when you just finished a new workflow and need data that 
goes back further than the date push your new code into production. In this situation you can simply use the
*start_date* parameter in a DAG to specify the start date. Airflow will then back-fill tasks to process that data
all the way back to that start date. It may not be appropriate or desirable to have so many execution runs to get
data up-to-date, so there are some other strategies that you can use to process weeks, months or years of data through
better parametrization of the DAGS. That will be documented in a separate story on this site. I've personally seen
cases where a lot of effort went into dealing with historical data loads and a lot of manual coding and workarounds
to achieve this. The idea is to make this effort repeatable and simple.

**Partition ingested data**: By partitioning data being ingested at the destination, you can parallellize dag runs,
avoid write locks on data being ingested and optimize performance when that same data is being read. It will also
serve as a historical snapshot of what the data looked like at specific moments in time for audit purposes. Partitions
that are no longer relevant can be archived and removed from the database.
  
**Enforce the idempotency constraint**:  The result of a DAG run should always have idempotency characteristics. This means that when you 
run a process multiple times with the same parameters (even on different days), the outcome is exactly the same. You do
not end up with multiple copies of the same data in your environment or other undesirable side effects. This is obviously
only valid when the processing itself has not been modified. If business rules change within the process, then the target
data will be different. It's a good idea here to be aware of auditors or other business requirements on reprocessing historic
data, because it's not always allowed. Also, some processes require anonimization of data after a certain number of days,
because it's not always allowed to keep historical customer data on record *forever*.

**Enforce deterministic properties**: A function is said to be deterministic if for a given input, the output produced is
always exactly the same. Examples of cases where behavior of a function can be non-deterministic:
    
    * Using external state within the function, like global variables, random values, stored disk data, hardware timers.
    * Operating in time-sensitive ways, like multi-threaded programs that are incorrectly sequenced or mutexed.
    * Relying on order of input variables and not explicitly ordering the input variables, but relying on accidental ordering
      (this can happen when you write results to a database in order and select without explicit ORDER BY statements)
    * Implementation issues with structures inside the function (implicitly relying on order in python dicts for example)
    * Improper exception handling and post-exception behavior
    * Intermediate commits and unexpected conditions
  
**Execute conditionally**:  Airflow has some options to control how tasks within DAGs are run based on the success of the 
instance that came before it. For example, the *depends_on_past* parameter specifies that all task instances before the 
one being executed must have succeeded before it executes the current one. The recently introduced *LatestOnlyOperator*
allows you to conditionally skip tasks downstream in the DAG if it’s not the most recent execution. There’s also the 
*BranchPythonOperator*, which can select which branch of execution proceeds in the DAG based on some decision function.

**Code workflow as well as the application**:  Most schedulers and workflow tools allow you to create steps and then define either in the UI 
or through XML how the steps are wired together. Eventually there will always be that particular job that becomes limited, 
because the logic of the workflow is not compatible with what you can do in the tool. In airflow, you do not just code 
the application process, you also code the workflow process itself. You can start new DAG's dynamically from within a DAG,
skip downstream tasks programmatically, use python functions to conditionally execute other code, run sub-dags and so on.
 
**Rest data between tasks**: To allow airflow to run on multiple workers and even parallelize task instances within 
the same DAG, you need to think where you save data in between steps. An airflow operator would typically read from one system, 
create a temporary local file, then write that file to some destination system. What you should not and even cannot do is depend on 
temporary data (files, etc.) that is created by one task in other tasks downstream. The reason is that task instances of the 
same DAG can get executed on different workers and that local resource won’t be there. When you use the Sequential or LocalExecutor 
you may seem to be able to get away with it, but if there is a need to use a distributed method of execution in the future 
and you have these dependencies, it can be very painful to fix them for each dag. It is therefore a good idea to ensure that 
data is read from services that are accessible to all workers and that you have data at rest within those services when 
tasks start and terminate.

**Understand SLA’s and alerts**: Service Level Agreements can be used to detect long running task instances and let airflow take further action. 
By default, airflow will email the missed SLA’s and these can be inspected further from the web server. In the DAG, you can 
specify a function that is to be called when there is an SLA miss, which is how you can communicate this to other communication channels.

**Parameterize subflows and dynamically run tasks**: Because the workflow is code, it is possible to dynamically create tasks or even 
complete dags through that code. There are some examples where people have a text file with instructions what they want processed and 
airflow simply uses that file to dynamically generate a dag with some parameterized tasks specific to that instruction file. 
There are downsides to this, for example if you generate new dag_id’s when the DAG is created, the web server will not show 
historical executions anymore, because it thinks the dag has been removed. 

The use of dynamic workflow specifications becomes more interesting within the context of subflows. If you have some routine code, 
for example checking the number of rows in a database and sending that as a metric to some service or potentially do some other checks, 
you can design that work as a “subdag” and use a factory method in a library to instantiate this functionality. 

**Pool your resources**: Simple schedulers keep no control over the use of resources within scripts. In airflow you can actually 
create resource pools and require tasks to acquire a token from this pool before doing any work. If the pool is fully used up, 
other tasks that require the token will not be scheduled until another token becomes available when another task finishes. 
This is very useful if you want to manage access to shared resources like a database, a gpu, a cpu, etc. 

**Sense when to start a task**: A lot of schedulers start tasks when a specific date / time has passed, exactly what cron does. 
Airflow can do this simple behavior, but it can also sense the conditions that are required before the rest of the dag will 
continue by using a sensor as the first task in the dag. Example sensors include a dag dependency sensor 
(which is triggered by a task instance result in another dag), an HTTP sensor that calls a URL and parses the result and sensors 
that detect the presence of files on a file system or data in a database. This provides a lot of tools to guarantee consistency 
in the overall ETL pipeline.

**Manage login details in one place**: Airflow maintains the login details for external services in its own database. You can refer to those 
configurations simply by referring to the name of that connection and airflow makes it available to the operator, sensor or hook. 
Not all schedulers do this properly; sometimes the workflow files contain these details (leading to duplication everywhere 
and a pain to update when it changes).

**Specify configuration details once**: Following the DRY principle, avoid duplication of configuration details by specifying them in a single
place once and look up the correct configuration from the code. Each airflow instance has "Variables" that can be set and looked up to
specify the context in which a task is run.

**Keep all metadata in one place**: You don’t need to do anything here. Airflow will manage logs, job duration, landing times in one place, 
which reduces the amount of overhead on people to collect this metadata in order to analyze problems. 

**Develop your own workflow framework**: Code as a workflow also allows you to reuse parts of DAG’s if you need to, reducing code duplication
and making things simpler in the long run. This reduces the complexity of the overall system and frees up developer time to work on more
important and impactful tasks. 
