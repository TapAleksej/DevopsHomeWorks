#!/bin/bash

input="$*"


# - Убираем лишние пробелы
# - Через awk оставляем только уникальные слова, сохраняя порядок
output=$(echo "$input" | tr -s ' ' | awk '{for(i=1;i<=NF;i++) if(!seen[$i]++) printf "%s ", $i}' | sed 's/ $//')


echo "$output"
