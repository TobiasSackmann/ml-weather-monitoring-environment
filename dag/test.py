from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import PythonOperator
import time

# Define a function to be used in the PythonOperator
def print_hello():
    print("Hello from Airflow!")

def sleep_for_a_bit():
    time.sleep(10)
    print("Slept for 10 seconds")

# Default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'start_date': datetime(2023, 9, 16),
}

# Define the DAG
with DAG(
    dag_id='test_airflow_dag',
    default_args=default_args,
    description='A simple test DAG for Apache Airflow',
    schedule_interval=timedelta(days=1),  # Runs once a day
    catchup=False,  # Disable catchup
    tags=['test'],
) as dag:

    # Start task
    start = DummyOperator(
        task_id='start'
    )

    # Task that prints "Hello from Airflow!"
    hello_task = PythonOperator(
        task_id='print_hello',
        python_callable=print_hello
    )

    # Task that sleeps for 10 seconds
    sleep_task = PythonOperator(
        task_id='sleep_task',
        python_callable=sleep_for_a_bit
    )

    # End task
    end = DummyOperator(
        task_id='end'
    )

    # Task dependencies
    start >> hello_task >> sleep_task >> end
