#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Проверяет сколько свободного места в основных разделах
# если мало выводит предупреждение, 
#если мало в калейде грохает базу калейда и создает заново в табличном пространстве
# если пространство  не создано нужно создать руками
import os
from threading import Thread
import subprocess
import queue
import  psycopg2
directory = ["/", "/home", "/var/lib/cyclops", "/var/lib/monoceros", "/var/lib/ssdb", "/var/log", "/var/lib/kaleid", "/srv", "/var/lib/kaleid-test"]
num_threads = 10
queues = queue.Queue()

def CheckFreeSpace (i, q):
    # for i in directory:
    while True:
        directory = q.get()
        if  os.path.exists(directory):
            st = os.statvfs(directory)
            du = st.f_bsize * st.f_bavail /1024 / 1024 / 1024
            # print(du, i)
            if du < 1:
                print(directory, du, "Осталось мало места!")
                if directory == "/var/lib/kaleid":
                    print (directory, "drop db")
                    subprocess.call("sudo -u postgres dropdb kaleid_training", shell=True)
                    subprocess.call("sudo -u postgres createdb kaleid_training --owner kaleid_training --tablespace kaleid_training", shell=True)
        else:
            print (directory, "not exist")
        q.task_done()        
    # num_threads = 10
    
for i in range(num_threads):
    worker  = Thread(target=CheckFreeSpace, args=(i, queues))
    worker.setDaemon(True)
    worker.start()
for directory in directory:
    queues.put(directory)
queues.join()
print ("Готово")

    
