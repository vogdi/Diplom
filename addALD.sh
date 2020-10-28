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
serverHost="$module"-storage"$doman"

function InstallUtil {

utils=(rpcbind 
     nfs-common 
     nfs-kernel-server 
     ald-server 
     ald-client-common 
     ald-server-common 
     smolensk-security-ald 
     ldap-utils
)
for i in ${utils[*]}; do
apt-get install "$i" -y -f 
echo $i
done


}



function PassFile {
    pass=(admin/admin:transas
secadmin:123
komandir:123
komandir_tr:123
shturman:123
shturman_tr:123
operator:123
operator1:123
operator2:123
operator3:123
operator1_tr:123
operator2_tr:123
operator3_tr:123
deshifrovshik:123
deshifrovshik1:123
deshifrovshik2:123
deshifrovshik3:123
deshifrovshik1_tr:123
deshifrovshik2_tr:123
deshifrovshik3_tr:123
nachraz:123
nachraz_tr:123)
exec 3>/etc/ald/pass.pass
for item in ${pass[*]}; do
    echo "$item" >&3
done
}

function AldConfig {
exec 3>/etc/ald/ald.conf
aldConfig=( "# This is a config file for Astra Linux Directory (ald) server and client.
# If values are altered - the following command should be invoked to update
# the server:
#
# $ ald-init   commit-config    (for server machine update) 
# $ ald-client commit-config    (for client machines update) 
#

#VERSION=1.5
VERSION=1.7
# Version of ald


DOMAIN=$doman
# The name of your domain (also used as Kerberos realm in upper-case).
# Should be in the form:
# .example.com
# !NOTE! (for ald-server). If this value is changed - the server should be
# reinitialized by:
# $ ald-init init
# Or you should use the commands 'ald-init backup-ldif' and 
# 'ald-init restore-backup-ldif'.


SERVER=$serverHost
# Fully qualified name of Astra Linux Directory server. 
# Should be in the form:
# my-ald-server.example.com


SERVER_ID=1
# Server identifier
# You need to make sure that the SERVER_ID of each ALD server in domain
# is different


DESCRIPTION=
# Host description


MINIMUM_UID=2500
# Users with UID less than this value are treated as local users, which are
# authenticated by local /etc/passwd and /etc/shadow.
# Astra Linux Directory will add global users starting from MINIMUM_UID.
# Global users are authenticated by Kerberos.
# You shoudn't set this value less than 1000 unless you know what you are doing.

DEFAULT_LOGIN_SHELL=/bin/bash
# Default login shell

DEFAULT_LOCAL_GROUPS=users,audio,video,scanner
# Default local groups for new domain users

ALLOWED_LOCAL_GROUPS=users,audio,video,scanner,cdrom,floppy,fuse
# Local groups are allowed on this machine for domain users

TICKET_MAX_LIFE=10h
# Maximum lifetime of credentials (if not renewed). 
# Should be in the form:
# NNd (for days) or NNh (for hours) or NNm (for minutes)
#
# !NOTE! that when a user ticket is expired - the user will lose access to his
# home directory. In this case he will need to log in again. 
# If a user wants his ticket to be renewed (manually or automatically) - he
# should use ald-renew-tickets(1) utility.
# Also note, that a ticket may be renewed if it's not expired yet.
#
# For convenience (to avoid renewal) this parameter can be set to a large value,
# for example, 30d. But this is less secure.
# Note, that a ticket will be destroyed anyway if a user logs out.


TICKET_MAX_RENEWABLE_LIFE=7d
# Maximum lifetime of credentials. The renewal of a ticket will be impossible
# after specified period, and it will expire anyway. A user will need to obtain
# a new ticket by kinit(1) or by logging in again.
#
# For convenience this parameter can be set to a large value, for example, 365d.
# But this is less secure.


NETWORK_FS_TYPE=cifs
# May be one of: none, nfs, cifs.
# Determines network filesystem type to store/mount home directories.
# If 'none' is set - no global filesystem is used and the following filesystem
# options are ignored.


SERVER_EXPORT_DIR=/ald_export_home
# This parameter applies only to ald-server. Specifies a path for real storage
# of user home directories on server. This directory is exported using
# Kerberos authentication.
# This parameter is ignored if NETWORK_FS_TYPE=none.


SERVER_ARCHIVE_DIR=/ald_archive_home
# This parameter applies only to ald-server. Specifies a path for storage
# of user home directories on server after user removal.
# This parameter is ignored if NETWORK_FS_TYPE=none.


#CLIENT_MOUNT_DIR=/ald_home
CLIENT_MOUNT_DIR=$aldHomedir
# Specifies a path where user home directories are mounted on client 
# machines.
# This parameter is ignored if NETWORK_FS_TYPE=none.


SERVER_FS_KRB_MODES=krb5i
# Specifies Kerberos modes for NFS4/CIFS (comma separated list).
# Valid modes:
#  krb5  - only authentication
#  krb5i - auth and integrity (packet signing, no encryption)
#  krb5p - auth, encryption. (ONLY FOR NFS4).
# Applies only to ald-server.
# This parameter is ignored if NETWORK_FS_TYPE=none.


CLIENT_FS_KRB_MODE=krb5i
# Specifies NFS4/CIFS Kerberos mode for client. May be one of krb5, krb5i, 
# krb5p (ONLY FOR NFS4).
# This parameter is ignored if NETWORK_FS_TYPE=none.


SERVER_POLLING_PERIOD=60
# This parameter applies only to ald-server. Specifies the ALDD task list
# polling period (in seconds).


SERVER_PROPAGATE_PERIOD=600
# This parameter applies only to ald-server. Specifies the database
# propagation period (in seconds).


CACHE_REFRESH_PERIOD=600
# This parameter applied only to ALD Cache Daemon. Specifies
# the cache refresh period.


UTF8_GECOS=1
# This parameter applies only to ald-server. Specifies changing
# LDAP schema for use UTF-8 in user GECOS field


SERVER_ON=0
# Status of the server. May be 1 or 0.
# (If 0, the client side on server machine is also switched off, 
#  i.e. CLIENT_ON = 0).
# When 0:
#  - Home directories are unexported.
#  - LDAP mechanism is excluded from nsswitch.
#  - All Kerberos principals are disabled (allow_tickets=0).
#  - LDAP, NFS4/Samba, Kerberos, nss-ldapd services are stopped. 
#  - nscd service is restarted.


CLIENT_ON=1
# Status of the client. May be 1 or 0.
# Applies only to ald-client.
# When 0:
#  - Home directories are unmounted.
#  - LDAP mechanism is excluded from nsswitch.
#  - nscd service is restarted."
)
for item in "${aldConfig[@]}"; do
    echo "$item" >&3
done
}



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

    InstallUtil
    PassFile
    AldConfig
    StatusAld
    AddPolicy
    AddUser
    AddUserTr
    AddHosts
    AddUserInHost
}

main