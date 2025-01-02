from unittest.mock import patch
from unittest import TestCase
import unittest
import sys


class TestDwdAPI(TestCase):

    @patch("requests.get")  # Mock the requests.get method
    @patch("builtins.print")
    def test_fetch_weather_data(self, mock_print, mock_get):
        # Arrange
        mock_response = mock_get.return_value
        mock_response.status_code = 200  # Set status code
        mock_response.json.return_value = {"weather": "sunny"}

        # Import the script to execute it with mocks
        sys.path.insert(1, "./notebooks")  # noqa: E402
        import dwd_api

        # Assert
        mock_get.assert_called_once_with(
            "https://dwdw.api.proxy.bund.dev/v30/stationOverviewExtended?stationIds=10838,10840"
        )
        mock_print.assert_called_with({"weather": "sunny"})


if __name__ == "__main__":
    unittest.main()
