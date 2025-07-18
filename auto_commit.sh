#!/usr/bin/env bash
set -o pipefail
set -x

git add .

last_hash=$(git log --oneline | head -1 | awk '{print $1}')


git commit -m "autocommit_${last_hash}"

echo "return code  $?"
chk=$(git log --oneline | head -2)

echo "$chk"

echo "Сделать отправку на гитхаб ? y/n"

read answer


if [ ${answer} -eq 'y' ]; then
	git pull 

	if [ $? -eq 0 ]; then
	  git push
	fi
fi
