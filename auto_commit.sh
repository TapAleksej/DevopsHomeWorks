#!/usr/bin/env bash
# set -o pipefail
# set -x

git add .

last_hash=$(git log --oneline | head -1 | awk '{print $1}')

echo "Примечание commit"
read comit

if [ ! "$comit" = "" ]; then
	git commit -m "$comit"
else	
	git commit -m "autocommit_${last_hash}"
fi


echo "return code  $?"
chk=$(git log --oneline | head -2)

echo "$chk"

echo "Сделать отправку на гитхаб? y/n"
read answer

answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [ "$answer" = "y" ] || [ "$answer" = "yes" ]; then
  git pull

  if [ $? -eq 0 ]; then
    git push
  else
    echo "Ошибка при git pull"
    exit 1
  fi
elif [ "$answer" = "n" ] || [ "$answer" = "no" ]; then
  echo "Операция отменена."
  exit 0
else
  echo "Неверный ввод. Введите 'y' или 'n'."
  exit 1
fi

