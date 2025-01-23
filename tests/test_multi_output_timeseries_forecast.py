import sys
import runpy
import pandas as pd


def test_multi_output_timeseries_forecast(mocker):
    # Arrange
    mocker.patch("mlflow.set_tracking_uri")
    mocker.patch("mlflow.set_experiment")
    mocker.patch("mlflow.autolog")
    mocker.patch("matplotlib.pyplot.show")

    expected_df = pd.read_json("./tests/resources/long_dataframe.json", orient="table")
    mock_query_api = mocker.patch("influxdb_client.InfluxDBClient.query_api")
    mock_query_api.return_value.query_data_frame = mocker.Mock(return_value=expected_df)

    original_resample = pd.DataFrame.resample

    def custom_resample(self, rule, *args, **kwargs):
        # Modify parameter "rule" to "s" if "h" is passed
        if rule == "h":
            rule = "s"
        return original_resample(self, rule, *args, **kwargs)

    mocker.patch.object(pd.DataFrame, "resample", custom_resample)

    # Act
    sys.path.insert(1, "./library")
    runpy.run_path("./notebooks/multi_output_timeseries_forecast.py")
