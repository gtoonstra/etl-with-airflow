from __future__ import print_function
import airflow
from datetime import datetime, timedelta
from airflow.operators.sensors import ExternalTaskSensor
from airflow import DAG
from airflow.operators.bash_operator import BashOperator

args = {
    'owner': 'airflow',
    'start_date': datetime(2019, 5, 6),
    'provide_context': True,
    'depends_on_past': True
}

dag = airflow.DAG(
    'process_dimensions',
    schedule_interval="@once",
    dagrun_timeout=timedelta(minutes=60),
    default_args=args,
    max_active_runs=1)

wait_for_cust_staging = ExternalTaskSensor(
    task_id='wait_for_cust_staging',
    external_dag_id='tutorial',
    external_task_id='sleep',
    execution_delta=None,  # Same day as today
    dag=dag)

wait_for_prod_staging = ExternalTaskSensor(
    task_id='wait_for_prod_staging',
    external_dag_id='t1',
    external_task_id='print_date',
    execution_delta=None,  # Same day as today
    dag=dag)
