#!/bin/bashSH

HASH="35a844e"
for file in *.py; do
  if [ -e "$file" ]; then
    base="${file%.py}"
    mv "$file" "${base}_${HASH}.py"
  fi
done  
