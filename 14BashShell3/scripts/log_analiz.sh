#!/usr/bin/env bash

ssh_sessions=$(who | awk '{print $1}' | sort | uniq -c)
echo "$ssh_sessions" | while read -r count user; do
  if (( count > 2 )); then
     echo "User $user have $count active sessions"
  fi
done
