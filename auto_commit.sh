#!/usr/bin/env bash
# set -o pipefail
#set -x

git add .		
		
last_hash=$(git log --oneline | head -1 | awk '{print $1}')


git commit -m "autocommit_${last_hash}" 

echo "return code  $?"
chk=$(git lst | head -2)
 
echo "$chk"
#echo "autocommit_$last_hash"
