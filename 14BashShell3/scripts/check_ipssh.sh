#!/usr/bin/env bash

filename="blocklist.txt"

mapfile -t ips < "$filename"


for ip in "${ips[@]}"; do
  echo "IP: $ip"
done


echo "sed"
set -x
echo $(sed -n '2p' $filename)


