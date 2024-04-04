#!/usr/bin/python3

import csv
from jinja2 import Environment, FileSystemLoader

# TODO: Add comment + documentation
hosts = {}
with open('host_ip.csv', newline='') as csvfile:
    hostreader = csv.reader(csvfile, delimiter=',')
    for row in hostreader:
        hosts[row[0]] = row[1]

environment = Environment(loader=FileSystemLoader('.'))
template = environment.get_template('inventory_template.j2')

with open("inventory.yml", "w") as inventory:
    inventory.write(template.render(hosts=hosts))
