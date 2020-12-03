#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import  psycopg2

def CreatKaleidDB():
    con = psycopg2.connect(
        user="postgres", 
        password="postgres", 
        host="10.10.72.177", 
        port="5432"
    )
    print("Database opened successfully")

    cursor = con.cursor()
    cursor.execute('DROP DATABASE  IF EXISTS kaleid_training')
    cursor.close()
    con.close()
CreatKaleidDB()