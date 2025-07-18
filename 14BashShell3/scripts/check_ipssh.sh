#!/usr/bin/env bash

filename="blocklist.txt"

mapfile -t ips < "$filename"


for ip in "${ips[@]}"; do
  echo "IP: $ip"
done

