#!/bin/bash
user=(secadmin komandir operator1 operator2 operator3 deshifrovshik1 deshifrovshik2 deshifrovshik3 shturman nachraz) 
usertr=(komandir_tr operator1_tr operator2_tr operator3_tr deshifrovshik1_tr deshifrovshik2_tr deshifrovshik3_tr shturman_tr nachraz_tr)
aldHomedir="/var/run/ald_home"
grouptr="TrainingUsers"
module="npu"
aldHost="$module"-arm
num=(01 02 03 04)
doman=".orion"
PublicFolderPath="/ald_export_home/publicfolder"
read -r -p "введите название модуля" module
ald-init init -f --pass-file=/etc/ald/pass.pass
ald-init start -f
statPolice="$(ald-admin policy-list --pass-file=/etc/ald/pass.pass --admin=admin/admin | grep -x orion)"
if [ "orion" == "$statPolice" ]; then
echo "$statPolice" exist
else
ald-admin policy-add orion --force --verbose --pass-file=/etc/ald/pass.pass --admin=admin/admin
ald-admin policy-mod orion --no-min-life --no-min-length --no-min-classes --no-history --no-max-failure --no-failure-count-interval --no-lock-out-duration --force --verbose --pass-file=/etc/ald/pass.pass --admin=admin/admin
ald-admin policy-get orion --force --verbose --pass-file=/etc/ald/pass.pass --admin=admin/admin 
fi

for item in ${user[*]}; do
    stat="$(ald-admin group-list | grep -x "$item")"
    statuser="$(ald-admin user-list | grep -x "$item")"
    # echo "$item"
    if [ "$stat" == "$item" ]; then
        echo "$item" exists
    else
        ald-admin group-add "$item" --force --verbose --pass-file=/etc/ald/pass.pass --admin=admin/admin
        echo creat "$item" group
    fi
    if [ "$statuser" == "$item" ]; then
    echo "$item" exists
    else
    ald-admin user-add "$item" --group="$item" --login-shell=/bin/bash --full-name="$item" --force --verbose --pass-file=/etc/ald/pass.pass --admin=admin/admin --policy=orion --home="$aldHomedir"/"$item"
     echo creat "$item" user

    fi
    # echo "$stat"
done
for item in ${usertr[*]}; do
stattr="$(ald-admin group-list | grep -x "$grouptr")"
statusertr="$(ald-admin user-list | grep -x "$item")"

if [ "$grouptr" == "$stattr" ]; then
    echo "$stattr" exist
else
ald-admin group-add "$grouptr" --force --verbose --pass-file=/etc/ald/pass.pass --admin=admin/admin
fi
if [ "$item" == "$statusertr" ]; then
    echo "$item" exist
      ald-admin user-rm "$item"  --force --verbose --pass-file=/etc/ald/pass.pass --admin=admin/admin

else
  ald-admin user-add "$item" --group="$grouptr" --login-shell=/bin/bash --full-name="$item" --force --verbose --pass-file=/etc/ald/pass.pass --admin=admin/admin --policy=orion --home="$aldHomedir"-training/"$item"
fi
done

for i in ${num[*]}; do
host="$aldHost""$i"
stathost="$(ald-admin host-list | grep -x "$host""$doman")"
echo "$host" !!!!!!!!!!!!!!!!!

if [ "$host""$doman" == "$stathost" ]; then
    echo "$host" exist
else
ald-admin host-add "$host" --host-desc="$host" --force --verbose --pass-file=/etc/ald/pass.pass --admin=admin/admin
fi
done
stathostkom="$(ald-admin host-list | grep -x "$aldHost"kom"$doman")"
if [ "$aldHost"kom"$doman" == "$stathostkom" ]; then
    echo "$aldHost"kom exist
else
ald-admin host-add "$aldHost"kom --host-desc="$aldHost"kom --force --verbose --pass-file=/etc/ald/pass.pass --admin=admin/admin

fi
