#!/usr/bin/env bash

user=(secadmin komandir operator1 operator2 operator3 deshifrovshik1 deshifrovshik2 deshifrovshik3 shturman nachraz) 
usertr=(komandir_tr operator1_tr operator2_tr operator3_tr deshifrovshik1_tr deshifrovshik2_tr deshifrovshik3_tr shturman_tr nachraz_tr)
aldHomedir="/var/run/ald_home"
grouptr="TrainingUsers"
module="npo"
armHost="$module"-arm
kvsHost="$module"-kvs
num=(01 02 03 04)
doman=".orion"
PublicFolderPath="/ald_export_home/publicfolder"
aldPass="--pass-file=/etc/ald/pass.pass"
aldAdmin="--admin=admin/admin"

function StatusAld {
    # checkAld="Сервер ALD активен."
    # statAld="$(ald-init status > status1 && grep $checkAld status1)"
    # echo "$statAld"
    # if  "Сервер ALD активен." == "$statAld"; then
    #     echo "ALD Active!"
    # else
    # echo "Activate ALD"
    ald-init init -f "$aldPass"
    ald-init start -f
    # fi
}

function AddPolicy {

    local stat
    stat="$(ald-admin policy-list "$aldPass" "$aldAdmin" | grep -x orion)"
    if [ "orion" == "$stat" ]; then
    echo "$stat" exist
    else
    echo "Install" "$stat"
    ald-admin policy-add orion --force --verbose "$aldPass" "$aldAdmin"
    ald-admin policy-mod orion --no-min-life --no-min-length --no-min-classes --no-history --no-max-failure --no-failure-count-interval --no-lock-out-duration --force --verbose "$aldPass" "$aldAdmin"
    ald-admin policy-get orion --force --verbose "$aldPass" "$aldAdmin"
    fi

}

function AddUser {
    local stat
    local statuser
    for item in ${user[*]}; do
        stat="$(ald-admin group-list | grep -x "$item")"
        statuser="$(ald-admin user-list | grep -x "$item")"
        if [ "$stat" == "$item" ]; then
            echo "$item" exists "$item" 
        else
            ald-admin group-add "$item" --force --verbose "$aldPass" "$aldAdmin"
            echo creat "$item" group
        fi
        if [ "$statuser" == "$item" ]; then
            echo "$item" exists
        else
            ald-admin user-add "$item" --group="$item" --login-shell=/bin/bash --full-name="$item" --force --verbose "$aldPass" "$aldAdmin" --policy=orion --home="$aldHomedir"/"$item"
            echo creat "$item" user

        fi
    done
}
function AddUserTr {
    local stat
    local statuser
    stat="$(ald-admin group-list | grep -x "$grouptr")"
    if [ "$grouptr" == "$stat" ]; then
            echo "$stat" exist
     else
            ald-admin group-add "$grouptr" --force --verbose "$aldPass" "$aldAdmin"
    fi

    for item in ${usertr[*]}; do
        statuser="$(ald-admin user-list | grep -x "$item")"

        if [ "$statuser" == "$item" ]; then
            echo "$item" exists "$item" 
         else
            ald-admin group-add "$item" --force --verbose "$aldPass" "$aldAdmin"
            echo creat "$item" group
        fi
        if [ "$item" == "$statuser" ]; then
            echo "$item" exist
         else
         ald-admin user-add "$item" --group="$grouptr","$item" --login-shell=/bin/bash --full-name="$item" --force --verbose "$aldPass" "$aldAdmin" --policy=orion --home="$aldHomedir"-training/"$item"
        fi
    done
}

function AddHosts {
    local host
    local stathost
    local stathostkom
    for i in ${num[*]}; do
        host="$armHost""$i"
        stathost="$(ald-admin host-list | grep -x "$host""$doman")"
        echo "$host" !!!!!!!!!!!!!!!!!

        if [ "$host""$doman" == "$stathost" ]; then
            echo "$host" exist
         else
            ald-admin host-add "$host" --host-desc="$host" --force --verbose "$aldPass" "$aldAdmin"
        fi
    done
    stathostkom="$(ald-admin host-list | grep -x "$armHost"kom"$doman")"
    if [ "$armHost"kom"$doman" == "$stathostkom" ]; then
        echo "$armHost"kom exist    
     else
        ald-admin host-add "$armHost"kom --host-desc="$armHost"kom --force --verbose "$aldPass" "$aldAdmin"
    fi

    for i in ${num[*]}; do
        host="$kvsHost""$i"
        stathost="$(ald-admin host-list | grep -x "$host""$doman")"
        echo "$host" !!!!!!!!!!!!!!!!!

        if [ "$host""$doman" == "$stathost" ]; then
            echo "$host" exist
         else
            ald-admin host-add "$host" --host-desc="$host" --force --verbose "$aldPass" "$aldAdmin"
        fi
    done
}

function AddUserInHost {
    local host
    for item in ${user[*]}; do
        for i in ${num[*]}; do
            host="$kvsHost""$i"
            ald-admin user-ald-cap "$item" --add-hosts --host="$host" --force --verbose "$aldPass" "$aldAdmin"
        done
    done

    for item in ${user[*]}; do
        for i in ${num[*]}; do
            host="$armHost""$i"
            ald-admin user-ald-cap "$item" --add-hosts --host="$host" --force --verbose "$aldPass" "$aldAdmin"
        done
    done


}

function main {
    # StatusAld
    AddPolicy
    AddUser
    AddUserTr
    AddHosts
    AddUserInHost
}

main