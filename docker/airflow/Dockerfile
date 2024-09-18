# Use the official Apache Airflow image as the base image
# Make sure to use the version you want
FROM apache/airflow:2.7.2  

COPY requirements.txt /

# Install the influxdb-client Python package
RUN pip install --no-cache-dir -r /requirements.txt

# Ensure the correct user is set to airflow (Airflow runs as this user by default)
USER airflow
