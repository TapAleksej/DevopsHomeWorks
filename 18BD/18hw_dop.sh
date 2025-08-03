Установка сервера

sudo apt update 
#sudo apt install -y mariadb-server 

sudo apt install -y mariadb-server mariadb-client
Статус
sudo systemctl status mariadb

sudo systemctl start mariadb
sudo systemctl status mariadb
sudo systemctl enable mariadb
Безопасные настройки (внести пароль для root)

для данного примера не ставлю
sudo mysql_secure_installation

export DB_PASSWORD=":tcbylf2022"
mysql -u root -p${DB_PASSWORD}

### Создать БД (mysql/postgres) surf_shop, в ней добавить таблицы
create database surf_shop;
use surf_shop;


CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150),
    description VARCHAR(500)
);
					
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    title VARCHAR(100),
    description VARCHAR(500),
    price DECIMAL(10, 2),
    stock INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);


CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    fullname VARCHAR(50),
    email VARCHAR(50),
    phone VARCHAR(10)
);


CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status SMALLINT,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);					
							
#### Добавить данные в таблицы (5-10 записей)
							
insert into categories (title, description)
values ('News', 'news in world'),('Show', 'camedy'),('Film','2000'),('Animals', 'Dogs and cats');							

insert into products (category_id, title, description, price, stock)
values (1, 'News','News in world', 20000, 10), (2,'Show', 'camedy', 250, 5), (3,'Film','2000', 5, 1), (4,'Animals', 'Dogs and cats', 1000,500);

insert into customers (username, fullname, email, phone)
values ('Niki', 'Jile', 'afad@ya.ru', '32234545'), ('Andersen', 'Hanz', 'ander@ya.ru', '2454555'),('Gete', 'Jim', 'gete@ya.ru', '5646546'),
('Sofa', 'Meru', 'sdg@ya.ru', '657565');

insert into orders (customer_id, order_date, status, total_amount)
values (4, '2025-05-01', 1, 20), (2, '2022-05-01', 3, 12),(4, '2025-05-20', 4, 5),(1, '2025-01-01', 4, 12),(4, '2021-06-20', 1, 2);

 insert into order_items (order_id, product_id, quantity, price)
 values (1, 2, 5, 200),(3, 2, 4, 200),(4, 3, 10, 1200),(5, 1, 15, 150),(3, 2, 1, 20),(2, 3, 15, 356);
 
 
## Написать скрипт для резервного копирования БД с помощью внешних инструментов
 
 Ручками делаем резервную копию
 sudo tar -czvf mysql_backup.tar.gz /var/lib/mysql/
 или
 sudo mv /var/lib/mysql /var/lib/mysql_backup_$(date +%F)
 
 
sudo apt update
sudo apt install -y mariadb-backup

sudo mkdir /Homework/backup

Скопируем на всякий базы
sudo mkdir /Homework/mysqlvar
sudo cp -R /var/lib/mysql  /Homework/mysqlvar/

скрипт для резервного копирования БД с помощью `mariadb-backup`
sudo mariabackup --backup --target-dir=/Homework/backup --user=root --password=${DB_PASSWORD}

```

[00] 2025-08-02 11:42:09 Redo log (from LSN 80841 to 80857) was copied.
[00] 2025-08-02 11:42:09 completed OK!

```

ls /Homework/backups/

aria_log.00000001  ibdata1      performance_schema  xtrabackup_checkpoints
aria_log_control   ib_logfile0  surf_shop           xtrabackup_info
backup-my.cnf      mysql        sys

После создания резервной копии её нужно подготовить для восстановления:
sudo mariabackup --prepare --target-dir=/Homework/backups/


### Восстановление данных руками
# sudo cp -r /var/lib/mysql_backup_2025-08-02/* /var/lib/mysql/
# sudo chown -R mysql:mysql /var/lib/mysql
sudo systemctl stop mariadb
sudo mariabackup --copy-back --target-dir=/Homework/backups/
sudo chown -R mysql:mysql /var/lib/mysql
sudo systemctl start mariadb

sudo rm -rf /Homework/backups/*
ls /Homework/backups/

sudo rm -rf /var/lib/mysql/*


sudo /usr/bin/mariabackup --prepare --target-dir=/home/alrex/Homework/backup/
sudo /usr/bin/mariabackup --copy-back --target-dir=/home/alrex/Homework/backup/ 

### Скриптование

#### Скрипт run_bkp.sh предназначен для создания и восстановления бд mariadb с помощью mariabackup

Скрипт выполняет проверку запуска - запущен ли он от sudo.

Имеет 2 режима (варианты переменной).

Режим create
- Создаёт, если не существует папку для архива.
- Создаёт архив с помощью mariabackup
- в текущей директории создаст копию текущего каталога бд `/var/lib/mysql` 
	в виде архива mysql_backup_2025-08-03_07-54.tar.gz .

Режим restore
- проверяет существование папки с архивом
- проверка существования файлов в папке для архивов
- в случае успешных проверок 
- подготавливает данные для восстановления (prepare)
- останавливает сервис mariadb
- делает очистку в каталоге `/var/lib/mysql`
- проводит восстановление из backup файлов в `/var/lib/mysql`
- меняет владельца и группу данной папки и файлов рекурсивно на mysql
- запускает сервис mariadb

run_bkp.sh
```bash
#!/usr/bin/env bash

set -euo pipefail

DIRECTORY_BACKUP="/home/alrex/Homework/backup/"
DEFAULTS="--defaults-file=/etc/mysql/debian.cnf"
SQL_DIRECTORY="/var/lib/mysql"
NAME_BACKUP="mysql_backup_$(date '+%Y-%m-%d_%H-%M').tar.gz"


if [ $(id -u) -ne 0 ]; then
    echo "Need root privileges (sudo)"
    exit 1
fi

case "$1" in
    "create")
                # clear directory backup
                if [ ! -d "${DIRECTORY_BACKUP}" ]; then
                        mkdir -p "${DIRECTORY_BACKUP}"
                else
                        rm -rf "${DIRECTORY_BACKUP}"/* > /dev/null
                fi

                # begin backup
                if /usr/bin/mariabackup --backup --target-dir="${DIRECTORY_BACKUP}" --user=root ; then

                        # copy sql directory
                        tar -czvf "${NAME_BACKUP}" "${SQL_DIRECTORY}"
                        echo "Backup comleted"
                        exit 0
                        else
                        echo "Backup failed"
                fi
        ;;
    "restore")
               if [ ! -d "${DIRECTORY_BACKUP}" ]; then
                        echo "Not present backup in ${DIRECTORY_BACKUP}"
                        exit 1
                elif [ -z "$( ls -A "${DIRECTORY_BACKUP}")" ]; then
                        echo "files in folder ${DIRECTORY_BACKUP} not found"
                        exit 1
               fi

                # prepare befor restore. Mariadb service must be run
                if ! /usr/bin/mariabackup --prepare --target-dir="${DIRECTORY_BACKUP}"; then
                        echo "not prepared restore"
                        exit 1
                fi

                systemctl stop mariadb

                 # clear old data in sql directory
                rm -rf "${SQL_DIRECTORY}"/*  > /dev/null


                # begin restore
                if ! /usr/bin/mariabackup --copy-back --target-dir="${DIRECTORY_BACKUP}" ; then
                        echo "not restored backup"
                        exit 1
                fi
                # set back owner mysql
                chown -R mysql:mysql "${SQL_DIRECTORY}"

                systemctl start mariadb

                echo "Restore completed"
                exit 0
        ;;
esac

```	

sudo ./run_bkp.sh create
```
[00] 2025-08-02 12:30:15 Redo log (from LSN 80857 to 80873) was copied.
[00] 2025-08-02 12:30:15 completed OK!
Backup comleted

```



sudo ./run_bkp.sh restore
```
[01] 2025-08-02 12:22:58 Copying ./surf_shop/db.opt to /var/lib/mysql/surf_shop/db.opt
[01] 2025-08-02 12:22:58         ...done
[00] 2025-08-02 12:22:58 completed OK!
Restore completed

systemctl status mariadb
● mariadb.service - MariaDB 10.11.13 database server
     Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; preset: enabled)
     Active: active (running) since Sat 2025-08-02 12:22:59 UTC; 1min 12s ago
       Docs: man:mariadbd(8)

```
## Репликация

sudo vim /etc/mysql/mariadb.conf.d/50-server.cnf




sudo mysqldump --defaults-extra-file=/etc/mysql/backup.cnf surf_shop  > surf.sql

Перекинем на slave
rsync -av -e "ssh -p 1234" surf.sql alrex@192.168.50.34:/home/alrex/Homework

sudo mysql -u root  surf_shop < /home/alrex/Homework/surf.sql

use surf_shop;



change master to MASTER_HOST = '192.168.50.44', MASTER_USER = 'repl_user', MASTER_PASSWORD = 'replpass', MASTER_LOG_FILE = 'mariadb-bin.000003', MASTER_LOG_POS = 2081;
change master to MASTER_HOST = '192.168.50.34', MASTER_USER = 'repl_user', MASTER_PASSWORD = 'replpass', MASTER_LOG_FILE = 'mariadb-bin.000002', MASTER_LOG_POS = 10200;

start slave;
show slave status\G; Ошибок нет


insert into categories (title, description)
values ('Replica12', 'replication12');

Проверил - синк работает на обеих машинах

MariaDB [surf_shop]> select  * from categories;
+-------------+-----------+---------------+
| category_id | title     | description   |
+-------------+-----------+---------------+
|           1 | News      | news in world |
|           2 | Show      | camedy        |
|           3 | Film      | 2000          |
|           4 | Animals   | Dogs and cats |
|           5 | Replica   | replication   |
|           9 | Replica12 | replication12 |
+-------------+-----------+---------------+
6 rows in set (0.001 sec)

## Скрипт доступности

На `192.168.50.55`

```bash
#!/bin/bash

# Конфигурация
MASTER_HOST="192.168.50.44"  
MASTER_PORT=3306             
SLAVE_HOST="192.168.50.34"   
SLAVE_USER="root"            
SLAVE_PASSWORD="password"    

# проверка доступности master
check_master_availability() {
    nc -z "$MASTER_HOST" "$MASTER_PORT"
    return $?
}

# Функция для остановки репликации и промоушена slave
promote_slave_to_master() {
    echo "Master ($MASTER_HOST) is down. Promoting slave ($SLAVE_HOST) to master..."

    # Остановить репликацию
    mysql -u"$SLAVE_USER" -p"$SLAVE_PASSWORD" -h"$SLAVE_HOST" -e "STOP SLAVE;"

    # Промоутнуть slave в master
    mysql -u"$SLAVE_USER" -p"$SLAVE_PASSWORD" -h"$SLAVE_HOST" -e "RESET SLAVE ALL;"

    echo "Slave ($SLAVE_HOST) has been promoted to master."
}

# Основной процесс
if check_master_availability; then
    echo "Master ($MASTER_HOST) is available. No action needed."
else
    echo "Master ($MASTER_HOST) is not available. Initiating failover..."
    promote_slave_to_master
fi
```




 sudo ./chr.sh
Connection to 192.168.50.44 3306 port [tcp/mysql] succeeded!
Master (192.168.50.44) is available. No action needed.

```
# 192.168.50.44 master
sudo systemctl stop mariadb

```

sudo ./chr.sh
Master (192.168.50.44) is not available. Initiating failover...
Master (192.168.50.44) is down. Promoting slave (192.168.50.34) to master...
./chr.sh: line 21: mysql: command not found
./chr.sh: line 24: mysql: command not found
Slave (192.168.50.34) has been promoted to master.
alrex@ubuntu1:~/Homework/DevopsHomeWorks$

# 192.168.50.44 master
sudo systemctl start mariadb

 sudo ./chr.sh
Connection to 192.168.50.44 3306 port [tcp/mysql] succeeded!
Master (192.168.50.44) is available. No action needed.
alrex@ubuntu1:~/Homework/DevopsHomeWorks$



