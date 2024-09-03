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
    ```
* Create/Train your Machine Learnign Model.
    * You should first run the feature selektion notebook(feature_selection.ipynb) from within the notebooks direcory.
    * Then run your desired notebook for training a model. For example timeseries_forecast_approach_evaluation.ipynb
    * Put it in a docker container. For tensorflow/keras model you can use the dockerfile ins the docker directory. Example:
        ```shell
        docker build -t weather-forecast .
        ```
    * Install it in the kubernetes cluster
    * Visualize your raw data as well as the machine learning results in Grafana

Technologies used
-----

* Kubernetes
* Docker
* Ansible
* Helm (within Ansible)
* Python/Jupyter Notebooks
* Tensorflow
* Shell
* InfluxDB
* Telegraf
* Grafana
* MLFlow
