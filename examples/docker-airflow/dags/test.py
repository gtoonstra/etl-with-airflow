from __future__ import print_function
import airflow
from datetime import datetime, timedelta
from airflow.operators.sensors import ExternalTaskSensor
from airflow.operators.bash_operator import BashOperator

args = {
    'owner': 'airflow',
    'start_date': datetime(2019, 5, 7, 20, 48),
    'provide_context': True,
    'depends_on_past': True
}

dag = airflow.DAG(
    't1',
    schedule_interval="@once",
    dagrun_timeout=timedelta(minutes=60),
    default_args=args,
    max_active_runs=1)


# t1, t2 and t3 are examples of tasks created by instantiating operators
t1 = BashOperator(task_id="print_date", bash_command="date", dag=dag)