#!/usr/bin/env bash
set -x
namefile="medcenter_$(date '+%d_%m_%Y')"
homedir="/Homework/DevopsHomeWorks/17BD"
arh_dir="/mnt/smb/Obmen/backup"

DB_PASS=":tcbylf2022"
full_file_name="${homedir}/${namefile}.sql"

# Почистим директорию
sudo rm -r $arh_dir

# backup
sudo mysqldump -u root -p${DB_PASS} medcenter > "${name_file}.sql"

# Делаем архив
sudo tar -cvf "${arh_dir}/${namefile}.tar ${namefile}.sql" 
