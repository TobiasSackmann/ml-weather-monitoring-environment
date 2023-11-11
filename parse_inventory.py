#!/usr/bin/python3

import csv

# TODO: Add comment + documentation
hosts = {}
with open('host_ip.csv', newline='') as csvfile:
    hostreader = csv.reader(csvfile, delimiter=',')
    for row in hostreader:
        hosts[row[0]] = row[1]

print(hosts)