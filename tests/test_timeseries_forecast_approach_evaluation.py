import sys
import pandas as pd
import runpy


def test_forecast_approach_evalusation(mocker):
    # Arrange
    mocker.patch("mlflow.set_tracking_uri")
    mocker.patch("mlflow.set_experiment")
    mocker.patch("mlflow.autolog")
    mocker.patch("matplotlib.pyplot.show")
    expected_df = pd.read_json("./tests/resources/long_dataframe.json", orient="table")
    mock_query_api = mocker.patch("influxdb_client.InfluxDBClient.query_api")
    mock_query_api.return_value.query_data_frame = mocker.Mock(return_value=expected_df)

    # Import the script to execute it with mocks
    sys.path.insert(1, "./library")
    runpy.run_path("./notebooks/timeseries_forecast_approach_evaluation.py")
