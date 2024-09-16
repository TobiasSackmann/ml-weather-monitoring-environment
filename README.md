# Machine Learning Weather Monitoring Environment

Repository for creating a Kubernetes based monitoring environment for DWD weather data.

Requirements
------------
* A Kubernetes Cluster. This Repository is supposed to be used in combination with my [proxmox-k3s repo](https://github.com/TobiasSackmann/proxmox-k3s), but can easily be amended to be used with any kubernetes cluster.
* Python3 is locally installed with packages
    * jinja2
    * mlflow
    * influxdb_client
    * pickle
    * scikit-learn
    * pandas
    * matplotlib
    * seaborn
    * numpy
    * tensorflow

Usage
-----
* Execute the setup.sh script from the setup direcory.
    * First Create a inventory.yml. It should look like this example.
        ```shell
        ---
        k3s_cluster:
        children:
            server:
            hosts:
                192.168.178.196
        ```
    * Execute the install playbook.
        ```shell
        ansible-playbook install.yml -i ./inventory.yml
        ```
* In case you do not have DNS in you network, you need to amend your /etc/hosts file by adding the following entries. 1.2.3.4 should be replaced by the ip of your new virtual VM.
    ```shell
    1.2.3.4    tig.grafana.local
    1.2.3.4    tig.influxdb.local
    1.2.3.4    mlflow.local
    1.2.3.4    apache-airflow.local
    ```
* Create/Train your Machine Learning Model.
    * You should first run the feature selektion notebook(feature_selection.ipynb) from within the notebooks direcory.
    * Then run your desired notebook for training a model. For example multi-output_timeseries_forecast.ipynb.ipynb. All steps below will assume you use this notebook. You will need to adapt command and file if you use another notebook/model.
* Put it in a docker container. For tensorflow/keras model you can use the dockerfile ins the docker directory. Example:
    ```shell
    docker build -t weather-forecast .
    ```
* Install it in the kubernetes cluster. The steps below provide an example for 
    * Provide your images to the local registry which was installed by the install.yaml playbook.
        ```shell
        docker save -o weather-forecast.tar weather-forecast
        scp weather-forecast.tar YOUR_USER@192.168.178.196:/home/YOUR_USER/
        ssh YOUR_USER@YOUR_VM_IP
        sudo docker load -i ./weather-forecast.tar
        sudo docker tag weather-forecast YOUR_VM_IP:5000/weather-forecast
        sudo docker push YOUR_VM_IP:5000/weather-forecast
        ```
    * Install the service and the deployment.
        ```shell
        kubectl apply -f deployment.yaml
        kubectl apply -f service.yaml
        ```
* Visualize your raw data as well as the machine learning results in Grafana

Testing
-----
```shell
docker run -p 8501:8501 weather-forecast
```

Technologies used
-----

* Kubernetes
* Docker
* Ansible
* Jinja
* Helm (within Ansible)
* Python/Jupyter Notebooks
* Tensorflow
* Shell
* InfluxDB
* Telegraf
* Grafana
* MLFlow
