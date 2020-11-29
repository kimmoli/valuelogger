#!/usr/bin/python

import argparse
import csv
import datetime
import sqlite3

parser = argparse.ArgumentParser()
parser.add_argument('src_db', help='Path to valueLoggerDb.sqlite')
parser.add_argument('-o', '--output', metavar='dest_file', default='valuelogger_dump_for_TracknGraph.csv',
        help='Path to resulting csv file (default: %(default)s)')
args = parser.parse_args()


conn = sqlite3.connect(args.src_db)
#param_cursor = conn.sursor()
value_cursor = conn.cursor()

with open(args.output, 'w', newline='') as csvfile:
    fieldnames = ['FeatureName','Timestamp','Value','Note']
    writer = csv.writer(csvfile)
    writer.writerow(fieldnames)
    LOCALTZ = datetime.datetime.now().astimezone().tzinfo
    for param_row in conn.cursor().execute('SELECT parameter,datatable FROM parameters'):
        for value_row in conn.cursor().execute('SELECT timestamp, value, annotation FROM %s' % ('_'+param_row[1])):
            row_for_csv = [param_row[0]] + list(value_row)
            try:
                timestamp = datetime.datetime.strptime(value_row[0], '%Y-%m-%d %H:%M:%S')
            except:
                timestamp = datetime.datetime.strptime(value_row[0], '%Y-%m-%d ')
            timestamp = timestamp.replace(tzinfo=LOCALTZ)
            row_for_csv[1] = timestamp.isoformat()
            writer.writerow(row_for_csv)
