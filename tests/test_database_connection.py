from unittest.mock import patch
from unittest import TestCase
import unittest
import runpy


class TestDwdAPI(TestCase):

    @patch("influxdb_client.InfluxDBClient.ready")
    # @patch("builtins.print")
    def test_fetch_weather_data(self, mock_ready):  # mock_print,
        # Arrange
        mock_response = mock_ready.return_value
        mock_response.status = "ready"

        # Import the script to execute it with mocks
        runpy.run_path("./notebooks/database_connection.py")

        # Assert
        mock_ready.assert_called_once_with()


if __name__ == "__main__":
    unittest.main()
