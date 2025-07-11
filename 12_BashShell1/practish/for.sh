#!/bin/bash
DIR=$1

if [ $# -eq 0 ]; then
    echo "Не указан параметр"
    exit 1
fi

if [ -d $DIR ]; then
    for file in $(find "$DIR" -type f);do
        line=$(ls -lh "${file}") 
        size=$(echo "$line" | awk {'print $5'})
        permissions=$(echo "$line" | awk {'print $1'})
        name=$(echo "$line" | awk {'print $9'})
 
        echo -e "      Файл: $name \nРазмер: $size \nПрава: $permissions"     
#  size_kb=$(stat -c "%s" "$file") 2> /dev/null
       # echo "$size_kb" &2> /dev/null           
#echo $'Файл:  $:{file} \n Размер: ${size_kb}'
    done
else
    echo "Нет каталога ${DIR}"
    exit 1
fi
