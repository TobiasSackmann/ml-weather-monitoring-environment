from unittest.mock import patch
from unittest import TestCase
import unittest
import sys
import pandas as pd

class TestIsolationForest(TestCase):

    @patch("matplotlib.pyplot.show")
    @patch("influxdb_client.InfluxDBClient.query_api")
    @patch("mlflow.autolog")
    def test_isolationforest(self, mock_autolog, mock_query, mock_show):
        # Arrange
        mock_show.return_value = None
        mock_autolog.return_value = None
        mock_query.return_value.query_data_frame.return_value = pd.read_json("./tests/resources/isolation_forest.json", orient="table")

        # Import the script to execute it with mocks
        sys.path.insert(1, "./notebooks")  # noqa: E402
        sys.path.insert(1, "./library")
        import isolation_forest_with_pca # type: ignore


if __name__ == "__main__":
    unittest.main()