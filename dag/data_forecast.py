import json
import requests
import numpy as np
from datetime import datetime, timedelta
import pytz
from airflow import DAG
from airflow.operators.python import PythonOperator
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
from utils import database_helper
import pickle
import pandas as pd


# InfluxDB configuration
INFLUXDB_URL = "http://influxdb-influxdb2.monitoring.svc.cluster.local:80"
INFLUXDB_TOKEN = "securetoken"
INFLUXDB_ORG = "influxdata"
INPUT_BUCKET = "default"
OUTPUT_BUCKET = "forecast"

# TensorFlow Serving configuration
TF_SERVING_URL = "http://weather-forecast.machinelearning.svc.cluster.local:8501/v1/models/waether-timeseries-forecasts:predict"

# Default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
    'start_date': datetime(2023, 9, 16),
}

# InfluxDB client setup
client = InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG)
query_api = client.query_api()
write_api = client.write_api(write_options=SYNCHRONOUS)

def generate_timestamps(n):
    # Aktuelle Zeit in Berliner Zeitzone (CET/CEST)
    now = datetime.now(pytz.timezone('Europe/Berlin'))
    timestamps = []
    # Erstelle 'n' Timestamps, die jeweils 1 Stunde auseinanderliegen
    for i in range(n):
        timestamp = now + timedelta(hours=i+1)
        timestamps.append(timestamp.strftime('%Y-%m-%d %H:%M:%S%z'))
    return timestamps

# Step 1: Function to read data from InfluxDB
def read_from_influxdb():
    selected_columns = ['10838_days_0_precipitation',
                        '10838_days_0_sunrise',
                        '10838_days_0_sunset',
                        '10838_days_0_sunshine',
                        '10838_days_0_temperatureMax',
                        '10838_days_0_temperatureMin',
                        '10838_days_0_windDirection',
                        '10838_days_0_windGust',
                        '10838_days_0_windSpeed']
    strings_to_exclude = ['icon', 'moon', 'warning']
    selected_columns = [item for item in selected_columns if not any(substring in item for substring in strings_to_exclude)]
    strings_to_include = ['days_0', '10838']
    selected_columns = [item for item in selected_columns if all(substring in item for substring in strings_to_include)]
    return database_helper.query_data(url=INFLUXDB_URL, field_list=selected_columns)

# Step 2: Function to Preprocess the Dataframe
def preprocess_dataframe(df):
    df.set_index('_time', inplace=True)
    df = df.select_dtypes(include='float64')
    df.interpolate(inplace=True)
    df = df.resample('h').mean()
    df.reset_index(inplace=True)
    date_time = pd.to_datetime(df.pop('_time'), format='%d.%m.%Y %H:%M:%S')
    
    timestamp_s = date_time.map(pd.Timestamp.timestamp)
    day = 24*60*60
    year = (365.2425)*day
    df['Day sin'] = np.sin(timestamp_s * (2 * np.pi / day))
    df['Day cos'] = np.cos(timestamp_s * (2 * np.pi / day))
    df['Year sin'] = np.sin(timestamp_s * (2 * np.pi / year))
    df['Year cos'] = np.cos(timestamp_s * (2 * np.pi / year))

    df = (df - df.mean()) / df.std()
    return df

# Step 3: Function to send data to TensorFlow Serving
def send_to_tf_serving(df):
    time_range = 24
    df = df[:time_range]
    df.reset_index(drop=True, inplace=True)
    data = json.dumps({"signature_name": "serving_default", "instances": np.array(df).tolist()})

    if data:
        headers = {"content-type": "application/json"}
        response = requests.post(TF_SERVING_URL, data=data, headers=headers)
        if response.status_code == 200:
            predictions = response.json()["predictions"]
            return [predictions, list(df.columns)]
        else:
            raise ValueError(f"Failed to get response from TF Serving: {response.text}")
    return None

# Step 4: Function to write data back to InfluxDB
def write_to_influxdb(result):
    predictions = result[0]
    columns = result[1]
    timestamps = generate_timestamps(len(predictions))
    if predictions:
        for i, prediction in enumerate(predictions):
            point = Point("inference_result").time(timestamps[i])
            for y, field in enumerate(prediction):
                point.field(columns[y], float(prediction[y]))
            write_api.write(bucket=OUTPUT_BUCKET, org=INFLUXDB_ORG, record=point)
        print("Predictions written to InfluxDB")

# Define the DAG
with DAG(
    dag_id='influxdb_to_tensorflow_dag',
    default_args=default_args,
    description='DAG that reads data from InfluxDB, processes it with TensorFlow Serving, and writes it back to InfluxDB',
    schedule_interval='@daily', # This will run the DAG every 24 hours
    catchup=False,
    tags=['tensorflow', 'influxdb'],
) as dag:

    # Task 1: Read data from InfluxDB
    read_data_task = PythonOperator(
        task_id='read_data_from_influxdb',
        python_callable=read_from_influxdb
    )

    # Task 2: Preprocess Data
    preprocess_data_task = PythonOperator(
        task_id='preprocess_data',
        python_callable=lambda ti: preprocess_dataframe(ti.xcom_pull(task_ids='read_data_from_influxdb'))
    )

    # Task 3: Send preprocessed data to TensorFlow Serving
    send_to_tf_task = PythonOperator(
        task_id='send_data_to_tensorflow',
        python_callable=lambda ti: send_to_tf_serving(ti.xcom_pull(task_ids='preprocess_data'))
    )

    # Task 4: Write the results back to InfluxDB
    write_data_task = PythonOperator(
        task_id='write_data_to_influxdb',
        python_callable=lambda ti: write_to_influxdb(ti.xcom_pull(task_ids='send_data_to_tensorflow'))
    )

    # Define task dependencies
    read_data_task >> preprocess_data_task >> send_to_tf_task >> write_data_task
