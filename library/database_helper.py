#!/usr/bin/python3
"""
helper for constructing influxdb queries.

This module provides utility functions for database operations, including
connection handling and query execution.
"""


from influxdb_client import InfluxDBClient
from datetime import datetime, timedelta, timezone
import pandas as pd
import os


def query_data(
    url="http://tig.influxdb.local",
    token="",
    org="",
    bucket="",
    query="",
    start_time="2025-01-09T10:00:00Z",
    end_time="",
    field_list=None,
    query_range=5,
):
    """
    Execute the query towards influxdb.

    Args:
        url (integer): The number of desired timestamps
        token (string): The influxdb authentication token
        org (string): the influxdb2 org
        bucket (string):  the influxdb2
        start_time (string): The start of the query timerange
        end_time (string): The end of the query timerange
        field_list (list): The fileds to be queried
        query_range (integer): The amount of days contained in a bulk query (for long timeranges)

    Returns:
        Dataframe: A pandas Dataframe containing the query results.
    """
    token = os.getenv("INFLUXDB2_TOKEN") if token == "" else token
    org = os.getenv("INFLUXDB2_ORGANIZATION") if org == "" else org
    bucket = os.getenv("INFLUXDB2_BUCKET") if bucket == "" else bucket

    if end_time == "":
        current_datetime = datetime.now(timezone.utc)  # datetime.utcnow()
        end_time = current_datetime.strftime("%Y-%m-%dT%H:%M:%SZ")

    client = InfluxDBClient(url=url, token=token, org=org)
    query_api = client.query_api()

    dfs = []
    date_chunks = split_date_range(start_time, end_time, query_range)
    for i, (start, end) in enumerate(date_chunks):
        query = build_query(bucket, start, end, field_list)
        print(
            "Executing Query " + str(i + 1) + " from " + str(start) + " to " + str(end)
        )
        df = query_api.query_data_frame(query, org=org)
        print(df.shape)
        dfs.append(df)

    return pd.concat(dfs, ignore_index=True)


def build_query(bucket, start_time, end_time, field_list):
    """
    Build the query towards influxdb.

    Args:
        bucket (string):  the influxdb2
        start_time (string): The start of the query timerange
        end_time (string): The end of the query timerange
        field_list (list): The fileds to be queried

    Returns:
        query: The query as string.
    """
    query = f"""
    from(bucket: "{bucket}") 
    |> range(start: {start_time.strftime("%Y-%m-%dT%H:%M:%SZ")}, stop: {end_time.strftime("%Y-%m-%dT%H:%M:%SZ")})
    |> filter(fn: (r) => r["_measurement"] == "http")
    """
    if field_list is not None:
        list_length = len(field_list)
        query += "|> filter(fn: (r) =>"
        for counter, field in enumerate(field_list):
            query += f' r["_field"] == "{field}"'
            if counter < list_length - 1:
                query += " or"
        query += ")"
    query += (
        '\n|> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")'
    )
    return query


def split_date_range(start_date_str, end_date_str, query_range):
    """
    Split the timerange for bulk queries.

    Args:
        start_time (string): The start of the query timerange
        end_time (string): The end of the query timerange
        query_range (integer): The amount of days contained in a bulk query (for long timeranges)

    Returns:
        query: The query as string.
    """
    # Convert strings to datetime objects
    start_date = datetime.strptime(start_date_str, "%Y-%m-%dT%H:%M:%SZ")  # %Y-%m-%d
    end_date = datetime.strptime(end_date_str, "%Y-%m-%dT%H:%M:%SZ")  # %Y-%m-%d

    # Calculate the duration
    duration = end_date - start_date

    # Check if the duration is longer than 1 week
    time_delta = timedelta(days=query_range)

    if duration <= time_delta:
        # If duration is less than or equal to one week, return the range as is
        return [(start_date, end_date)]

    # Otherwise, split into 1-week chunks
    chunks = []
    current_start_date = start_date

    while current_start_date < end_date:
        current_end_date = min(current_start_date + time_delta, end_date)
        chunks.append((current_start_date, current_end_date))
        current_start_date = current_end_date

    return chunks
