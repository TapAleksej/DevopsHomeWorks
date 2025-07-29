#!/usr/bin/env bash
set -euo pipefail
#set -x
# Настройки
namefile="medcenter_$(date '+%Y-%m-%d')"
homedir="/Homework/DevopsHomeWorks/17BD"
arh_dir="/mnt/smb/Obmen/backup"
full_file_name="${namefile}.sql"
archive_name="$arh_dir/$namefile.tar"


cd "$homedir"
# Создаем директории, если их нет
mkdir -p "$arh_dir"

#log_file="${homedir}/backup.log"
log_file="$arh_dir/backup.log"

echo "Log file in: $log_file"



# Функция для логирования
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$log_file"
}

# Очистка старых бэкапов (например, старше 7 дней)
cleanup_old_backups() {
    log "Cleaning up old backups..."
    find "$arh_dir" -type f -mtime +7 -exec rm -f {} \;
}

# Создание дампа базы данных
create_backup() {
    log "Creating backup of database 'medcenter'..."
    if mysqldump --defaults-extra-file=/etc/mysql/backup.cnf medcenter > "$full_file_name"; then
        log "Backup successfully created: $full_file_name"        
    else
        log "Backup failed!"
        exit 1
    fi
}

 # проверка количества строк в sql
check_sql_file(){

  if [ ! -f "$full_file_name" ]; then
    log "Error: File $full_file_name does not exist!"
    return 1
  fi

  local records
  records=$(wc -l < "$full_file_name")  
  echo "$records"
}



# Копирование дампа в архивную директорию
copy_to_archive() {
    
    if tar -cvf "$archive_name" "$full_file_name"; then
          
        # test archive
        if tar -tvf "$archive_name" > /dev/null; then
            # remove not need sql file
            rm "$full_file_name"
            log "Backup successfully archived and checkit: $archive_name"
               # Изменяем владельца архива
            sudo chown alrex:alrex "$archive_name"
        else
            log "ERROR: Archive test failed: $archive_name"
            exit 1
        fi      
    else
      log "Failed to create archive!"
      exit 1
    fi
}


# Главная функция
main() {
    cleanup_old_backups
    create_backup
    # проверка содержания архива
    records=$(check_sql_file)
    if [ "$records" -lt 2 ]; then
        echo "Файл архива содржит менее 2х строк!!!!"
        log "ERROR: Backup file contains less than 2 records: $full_file_name"
        exit 1
    else
      copy_to_archive
      # sudo chown alrex:alrex /mnt/smb/Obmen/backup/
    fi      
    
}

# Запуск скрипта
main
