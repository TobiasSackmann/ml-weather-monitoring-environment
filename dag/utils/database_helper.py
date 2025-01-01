#!/usr/bin/python3
from influxdb_client import InfluxDBClient


def query_data(url="", token="", org="influxdata", bucket="default", field_list=None):

    client = InfluxDBClient(url=url, token=token, org=org)
    query_api = client.query_api()
    query = build_query(bucket, field_list)
    df = query_api.query_data_frame(query, org=org)

    return df


def build_query(bucket, field_list):
    query = f"""
    from(bucket: "{bucket}") 
    |> range(start: -24h)
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
