

# Machine Learning Weather Monitoring Environment

Repository for creating a monitoring environment for DWD weather data using Kubernetes and Machine Learning.

## Software

| Software            | Helm Chart    |
|---------------------|------------|
| ![Telegraf](https://img.shields.io/badge/Telegraf-v1.32.0-blue?logo=telegraf) | v1.8.54 |
| ![InfluxDB](https://img.shields.io/badge/InfluxDB-v2.7.4-brightgreen?logo=influxdb) | v2.1.2 |
| ![Grafana](https://img.shields.io/badge/Grafana-v11.2.1-orange?logo=grafana) | v8.5.2 |
| ![Apache Airflow](https://img.shields.io/badge/Apache%20Airflow-v2.9.3-blue?logo=apacheairflow) | v1.15.0 |
| ![MLflow](https://img.shields.io/badge/MLflow-v2.16.2-lightblue?logo=mlflow) | v2.0.0 |
| ![K3s/Kubernetes](https://img.shields.io/badge/Kubernetes-v1.26.9+k3s1-blue?logo=kubernetes) | - |
| ![Python](https://img.shields.io/badge/Python-v3.12.7-yellow?logo=python) | - |
| ![Ansible](https://img.shields.io/badge/Ansible-v2.18.0-red?logo=ansible) | - |
| ![Jinja](https://img.shields.io/badge/Jinja-v3.1.4-red?logo=jinja) | - |
| ![TensorFlow](https://img.shields.io/badge/TensorFlow-v2.17.0-orange?logo=tensorflow) | - |
| ![Scikit-learn](https://img.shields.io/badge/Scikit--learn-v1.5.1-blue?logo=scikitlearn) | - |
| ![Pandas](https://img.shields.io/badge/Pandas-v2.2.2-green?logo=pandas) | - |
| ![Helm](https://img.shields.io/badge/Helm-v3.16.3-purple?logo=helm) | - |
| ![Docker](https://img.shields.io/badge/Docker-v27.2.31-purple?logo=docker) | - |


The following picture shows an overview of the system components.

![image](./pictures/system-overview.png)

## Requirements
* A Kubernetes Cluster. This Repository is supposed to be used in combination with my [proxmox-k3s repo](https://github.com/TobiasSackmann/proxmox-k3s), but can easily be adjusted to be used with any kubernetes cluster.
* Python3 is locally installed with the packages from the requirements.txt.

## Usage
This repository deploys its component in two phases.
1. In the first phase it deploys all components that do not require a running Machine Learning Model. This is done with the install-ml-independent_software.yml ansible playbook.
2.  In the second phase the Machine Learning Model and Software that depend on a running Model are deploy.

Therefore it is mandatory to train and provide such a model as a docker container within the local registry. That registry will be deployed in phase 1.

### Phase 1
In this phase the basic setup is installed on the cluster.
* Before that playbook can be executed an inventory.yml is required in the setup directory. It should look like this example.
    ```shell
    ---
    k3s_cluster:
        children:
            server:
                hosts:
                    YOUR_KUBERNETES_IP
    ```
* For handling sensible data an ansible vault is also required in the setup directory. A sample-vault.yaml could look like this:
    ```shell
    # influxdb2
    influxdb2_user: admin
    influxdb2_password: password
    influxdb2_token: securetoken

    # mlflow
    mlflow_postgresql_user: bn_mlflow
    mlflow_postgresql_password: password
    mlflow_postgresql_database: bitnami_mlflow
    mlflow_minio_rootuser: admin
    mlflow_minio_rootpassword: password
    mlflow_serviceport_http: 30001
    mlflow_auth_username: user
    mlflow_auth_password: password
    mlflow_ingress_enabled: true

    grafana_secure_token: securetoken
    ```
* Execute the basic install ansible playbook. If a file for en-/decrypting the vault is used. The command is:
    ```shell
    ansible-playbook cluster_setup.yml -i ./inventory.yml --vault-password-file .vault_pass
    ```
* In case you do not have DNS in you network, you need to amend your /etc/hosts file by adding the following entries. 1.2.3.4 should be replaced by the IP of your Kubernetes Cluster. This will enable you to access the WebUi of InfluxDb, MlFlow and later also Grafana and Apache Airflow from the Webbrowser.
    ```shell
    1.2.3.4    tig.grafana.local
    1.2.3.4    tig.influxdb.local
    1.2.3.4    mlflow.local
    1.2.3.4    apache-airflow.local
    ```

### Machine Learning Model Training
Now the Machine Learning model needs to be created.
* Preparation for Training the Machine Learning Model.
    * An .env file should be created in the notebooks directory in order to handle sensitive data.
    Example content:
    ```shell
    INFLUXDB2_USER=admin
    INFLUXDB2_PASSWORD=password
    INFLUXDB2_TOKEN=securetoken
    INFLUXDB2_ORGANIZATION=influxdata
    INFLUXDB2_BUCKET=default
    INFLUXDB2_ML_BUCKET=forecast

    MLFLOW_AUTH_USERNAME=user
    MLFLOW_AUTH_PASSWORD=password
    MLFLOW_TRACKING_USERNAME=user
    MLFLOW_TRACKING_PASSWORD=password
    ```
    * Run the feature selection notebook feature_selection.ipynb from within the notebooks directory.
* Then run the desired notebook for training a model. The code of this repository and this README file assume that the multi-output_timeseries_forecast.ipynb was used for that purpose. Using another notebook or a model not coming from this repository will require code amendments.
* Put the new Machine Learning Model in a docker container. For tensorflow/keras model you can use the dockerfile ins the docker directory. Example:
    ```shell
    docker build -t weather-forecast .
    ```
* Install it in the local registry which was created in phase 1. The steps below provide an example for 
    * Provide your images to the local registry which was installed by the install.yaml playbook.
        ```shell
        docker save -o weather-forecast.tar weather-forecast
        scp weather-forecast.tar YOUR_USER@YOUR_IP:/home/YOUR_USER/
        ssh YOUR_USER@YOUR_VM_IP
        sudo docker load -i ./weather-forecast.tar
        sudo docker tag weather-forecast YOUR_VM_IP:5000/weather-forecast
        sudo docker push YOUR_VM_IP:5000/weather-forecast
        ```
    * Login to influxdb the username/password via webui and create your bucket "forecast"

### Testing the new Model
This command runs the new Machine Learning docker container.
```shell
docker run -p 8501:8501 weather-forecast
```

The notebook test_dockercontainer.ipynb provides an easy way of creating an inference by requesting it from the docker container.

### Phase 2
In this phase the final system components are deployed to the docker container.
* Build your custom apache airflow image. This might be required to install all necessary pip packages. A sample Dockerfile can be found in the docker/airflow directory.
```shell
    docker build -t YOUR_IP:5000/custom-airflow:YOUR_TAG .
    docker save -o custom-airflow.tar custom-airflow
    scp custom-airflow.tar YOUR_USER@YOUR_IP:/home/YOUR_USER/
    ssh YOUR_USER@YOUR_IP
    sudo docker load -i ./custom-airflow.tar
    sudo docker push YOUR_IP:5000/custom-airflow
```
* Execute the install playbook to deploy the machine learning model as well as grafana and apache airflow.
    ```shell
    ansible-playbook ml_monitoring_setup.yml -i ./inventory.yml --vault-password-file .vault_pass
    ```
