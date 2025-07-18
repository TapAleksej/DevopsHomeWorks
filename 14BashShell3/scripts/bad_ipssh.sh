#!/usr/bin/env bash

#set -x
LOGFILE="/var/log/auth_audit.log"
filename="blocklist.txt"

active_ssh_ip=$(who | sed 's/[()]//g' | awk '{print $3,  $1,  $5'} | uniq -c | awk '{ print $2,":",$3,":",$4,":"$1}')

#echo "$active_ssh_ip"
for ip in $(cat "$filename");do
    if echo "$active_ssh_ip" | grep -q "$ip"; then
        echo "$active_ssh_ip" | grep "$ip" >> "$LOGFILE" 
    fi
done

cat "$LOGFILE"
