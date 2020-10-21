#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from threading import Thread
import subprocess
import queue
import os
num_threads = 255
queues = queue.Queue()
num = 1
ips = ["10.10.74.1" , "10.10.74.2" , "10.10.74.3" , "10.10.74.4"]
a = ("10.10.121.")
ip = []
ipEnd= []
for n in range(1, 255):
    ip.append((a)+str(n))
def pinger(i, q):
    while True:
        ip = q.get()
        ret = subprocess.call("ping -c 1 %s" % ip, shell=True, stdout=open('/dev/null', 'w'), stderr=subprocess.STDOUT)
        if ret != 0:
                print ("%s: Свободный" % ip)
        q.task_done()
for i in range(num_threads):
    worker  = Thread(target=pinger, args=(i, queues))
    worker.setDaemon(True)
    worker.start()
for ip in ip:
    queues.put(ip)
print ("начинаю работу")
queues.join()
print ("Готово")