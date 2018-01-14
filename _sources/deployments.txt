Deployments
===========

Beyond deploying airflow on bare metal hardware or a VM you can also run airflow on container-based infrastructure
like docker swarm, Amazon ECS, Kubernetes or Minikube. 

This section details some of the approaches you can take to deploy it on some of these infrastructures and it highlights
some concerns you'll have to worry about to achieve success.


Template and deploy managed services
------------------------------------

My take is that managed services are preferred over kubernetes based deployments because they give you 
better control over high-availability configurations, backups and some other concerns.

This section documents some ideas on which and how to provision managed services that serve as the 
backbone infrastructure for an airflow deployment:

- **Managed database**: A database that has frequent backups. The database is used by airflow to keep track of 
  the tasks that ran from the dags. It also serves as a distributed lock service for some exotic use cases in airflow.
- **Distributed MQ**: Because kubernetes or ECS builds assumes pods or containers that run in a managed environment,
  there needs to be a way to send tasks to workers. This means that the CeleryExecutor is the most viable option. Airflow
  distributes tasks through the Celery interface only, so you're free to use any supported messaging backend for Celery *.
  Most people choose RabbitMQ or Redis as the backend.
- **Shared filesystem**: The docker images contain what I consider the 'core' part of airflow, which is the Apache Airflow
  distribution, any hooks and operators that you develop yourself, client installations of database drivers, etc. 
  The reason to use a shared file system is that if you were to include the DAG workflows inside the image, you'd have to
  make sure that all workers get updated with the new image. This means you're almost forced to stop all the worker instances
  and then synchronize scheduling a DAG you updated until after the DAG is available everywhere on every worker. Using a shared
  filesystem like EFS on AWS or a PersistentDisk that is mapped multiple times in read-only mode gives you a very easy way to
  manage this, because there will be a very limited time that updated dags are not necessarily synchronized everywhere.

.. important::
  * Some backends have certain drawbacks that might make them less suitable for airflow; for example the AWS SQS
  managed service sounds like the most logical backend to use on AWS, but you need to configure the visibility timeout to 
  the delay of the longest running task. If you're running tasks that take up to 8 hours to run, you'll be running with a 
  visibility timeout of 8+ hours!


It makes a lot of sense to template this work, because you may have to deploy airflow multiple times for different reasons:

- Separation between dev, acceptance and production environments
- Separation of code and/or executors inbetween teams, to guarantee that workers and workflows from one team do not negatively impact another
- Disaster Recovery


Continuous integration
----------------------

The suggested CI model requires at least two pipelines to be set up:

- A pipeline that compiles and deploys the 'core' platform with all the hooks, operators and generic function of your airflow installation.
  This pipeline would draw code from a code repository, build a docker image from the code and make that typically available from a registry
  somewhere. You'd probably develop and test the hooks on a local development machine somewhere (as per the other tips on keeping your
  development infrastructure small). Then you could have a setup where certain branches are merged to compile an "acceptance image" that is 
  deployed and used on the acceptance environment and a final "master" branch image build that is only deployed on production.
- Another pipeline to manage DAG deployments (on the shared file system) that might use branches or combinations of branches to test the impact
  of changing queries, DAGS and other code.

If you still prefer to have separation/isolation between your repositories, for example you don't want everyone to see the code that data scientists
are using or other teams, you can specify multiple source directories from which dags are read. This way, you can deploy the github repo's to each
corresponding subdirectory and maintain complete separation per repository. You can take this a step further by configuring workers to read from
specific directories only and then use the *queue* mechanism to direct tasks to those specific workers, although it will complicate your setup. 


Log files
---------

If you set up airflow this way then you're forced to push your log files to s3 or gcs because the lifetime of a pod is not guaranteed, they can
be very volatile. The good news is that workers can now survive failures quite easily, but log files are no longer persisted on the workers themselves.
Besides s3 and gcs there are other options on some systems which include redirecting all stdout/stderr and log files to a logging service
that is either native to the system or licensed (like splunk).
