#!/usr/bin/env bash

#set -x

filename="blocklist.txt"

active_ssh_ip=$(who | awk '{print $5}' | sed 's/[()]//g')

for ip in $(cat "$filename");do
    if echo "$active_ssh_ip" | grep -q "^$ip$"; then
      echo "${ip} попался"
    fi
done  
