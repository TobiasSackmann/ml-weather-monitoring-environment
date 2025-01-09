from unittest.mock import patch
from unittest import TestCase
import unittest
import sys
import pandas as pd


class TestFeatureSelection(TestCase):

    @patch("influxdb_client.InfluxDBClient.query_api") 
    #@patch("builtins.print")
    def test_feature_selection(self, mock_query):
        # Arrange
        mock_query.return_value.query_data_frame.return_value = pd.read_json("./tests/resources/feature_selection_dataframe.json", orient="table")

        # Import the script to execute it with mocks
        sys.path.insert(1, "./notebooks")  # noqa: E402
        sys.path.insert(1, "./library")
        import feature_selection # type: ignore


if __name__ == "__main__":
    unittest.main()
