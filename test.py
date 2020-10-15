#!/usr/bin/env python
from threading import Thread
import subprocess
import queue
import os

num_threads = 256
queues = queue.Queue()
num = 1
ips = ["10.10.74.1" , "10.10.74.2" , "10.10.74.3" , "10.10.74.4"]
a = ("10.10.121.")
b = (10)
c = (121)
ip = []
# def genIP():
for n in range(256):
    ip.append((a)+str(n))
    # print (ip)



def pinger(i, q):

    
    while True:
        ip = q.get()
        # print ("Theread %s Pinging %s" % (i, ip))
        ret = subprocess.call("ping -c 1 %s" % ip, shell=True, stdout=open('/dev/null', 'w'), stderr=subprocess.STDOUT)
        if ret == 0:
            print ("%s: is alive" % ip)
        else:
            print ("%s: did not respond" % ip)
        q.task_done()

for i in range(num_threads):
    worker  = Thread(target=pinger, args=(i, queues))
    worker.setDaemon(True)
    worker.start()
for ip in ip:
    queues.put(ip)

print ("Main thread waiting")
queues.join()

print ("Done")