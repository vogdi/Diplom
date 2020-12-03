#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import  psycopg2
kaleidtable = ["alembic_version", "attributes_history", "events_history", "sessions_history", "requests_history", "data_sources", "replies_history", "frames_batches", "frames", "sparse_frames"]

con = psycopg2.connect(
  database="kaleid_training", 
  user="postgres", 
  password="postgres", 
  host="10.10.72.177", 
  port="5432"
)

print("Database opened successfully")

cursor = con.cursor()
for kaleid in kaleidtable:
# cursor.execute('SELECT * FROM pg_tables')
# cursor.execute('SELECT * FROM sparse_frames  ')
    cursor.execute("TRUNCATE TABLE %s RESTART IDENTITY CASCADE" % kaleid)
    print(kaleid)
# for row in cursor:
#     print(row)
    con.commit()
cursor.close()
con.close()