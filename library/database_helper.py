#!/usr/bin/python3
from influxdb_client import InfluxDBClient

def query_data(
    url = 'http://tig.influxdb.local',
    token = "securetoken",
    org = "influxdata",
    bucket = "default",
    query = '',
    field_list = None):

    if query == '' or query == None:
        query = f'''
        from(bucket: "{bucket}") 
        |> range(start: -28h)
        |> filter(fn: (r) => r["_measurement"] == "http")
        '''
    if field_list is not None:
        list_length = len(field_list)
        query += '|> filter(fn: (r) =>'
        for counter, field in enumerate(field_list): #
            query += f' r["_field"] == "{field}"'
            if counter < list_length -1:
                query += ' or'
        query += ')'
    query += '\n|> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")'

    client = InfluxDBClient(url=url, token=token, org=org)
    query_api = client.query_api()
    return query_api.query_data_frame(query, org=org)