#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import ftplib
ftp_serv = "10.10.121.90"
local_dir = "~/test_ftp/"
ftp_dirs = ["20190329SE15/" , "20190329SE15_dev/" , "disk1/" , "disk2/"]
ftp_dir = "astra15"
for dirarr in ftp_dirs:
    ftp = ftplib.FTP(ftp_serv)
    ftp.login()
    filename = ftp.nlst("astra15/"+dirarr)
    ftp.cwd("astra15/"+dirarr)
    patch = ftp.pwd()
    for name, facts in ftp.mlsd():
        # print(name)
        # print(facts)
        for ripe in facts['type']:
            # print(ripe)
            if ripe == 'd':
                print(name)

    # print(patch)
