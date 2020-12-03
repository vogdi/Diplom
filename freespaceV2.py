#!/opt/tnt/bin/python3.8
# -*- coding: utf-8 -*-
# Проверяет сколько свободного места в основных разделах
# если мало выводит предупреждение, 
#если мало в калейде отчищает таблицы калейда
import os
from threading import Thread
import subprocess
import queue
import  psycopg2

kaleidtaible = ["alembic_version", "attributes_history", "events_history", "sessions_history", "requests_history", "data_sources", "replies_history", "frames_batches", "frames", "sparse_frames"]
directory = ["/", "/home", "/var/lib/cyclops", "/var/lib/monoceros", "/var/lib/ssdb", "/var/log", "/var/lib/kaleid/kaleid", "/var/lib/kaleid/kaleid_training", "/srv", "/var/lib/kaleid-test"]
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
                    ClearTable()
        else:
            print (directory, "not exist")
        q.task_done()        
    
def ClearTable():
    for kaleid in kaleidtaible:
        subprocess.call("sudo -u postgres psql -d kaleid_training -c \"TRUNCATE TABLE %s RESTART IDENTITY CASCADE\"" % kaleid, shell=True)
        print (kaleid)
    # subprocess.call("sudo -u postgres dropdb kaleid_training", shell=True)
    # subprocess.call("sudo -u postgres createdb kaleid_training --owner kaleid_training --tablespace kaleid_training", shell=True)
     

for i in range(num_threads):
    worker  = Thread(target=CheckFreeSpace, args=(i, queues))
    worker.setDaemon(True)
    worker.start()
for directory in directory:
    queues.put(directory)
queues.join()
print ("Готово")

    
