#!/usr/bin/bash
modulName="npo"
# hosts=("$modulName"-arm[0-4] "$modulName"-kvs[0-3] $modulName-storage)
hosts=("192.168.1.12" "192.168.1.13" "192.168.1.3" "192.168.1.2" "192.168.1.1" "192.168.1.4")
mask="192.168.1."
power="20"
connect=$(sshpass -p transas ssh root@10.10.73.149)
# while [[ $power -gt 0 ]] 
# do
# host=$mask$power
# check=$(ping -c1 "$host" )
# echo $host
# if "$connect""$check"
# then
# echo $check
# else
# echo $check not found

# fi

# power=$((power - 1))
# done
for host in [$hosts]
do
echo $host
done