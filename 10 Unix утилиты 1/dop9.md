# Пользователи и права доступа
#### Создать директорию /var/www/server-app; 
в ней файлы readme.md и app.log; директорию uploads
```
sudo mkdir /var/www/server-app
sudo touch /var/www/server-app/readme.md /var/www/server-app/app.log
sudo mkdir /var/www/server-app/uploads

ls -l /var/www/server-app
total 4
-rw-r--r-- 1 root root    0 Jul  1 08:28 app.log
-rw-r--r-- 1 root root    0 Jul  1 08:28 readme.md
drwxr-xr-x 2 root root 4096 Jul  1 08:31 uploads
```
Создать:
группу ftpusers
группу admins
группу auditors

```
sudo addgroup ftpusers
	info: Selecting GID from range 1000 to 59999 ...
	info: Adding group `ftpusers' (GID 1001) ...
sudo addgroup admins
	info: Selecting GID from range 1000 to 59999 ...
	info: Adding group `admins' (GID 1002) ...
sudo addgroup auditors
	info: Selecting GID from range 1000 to 59999 ...
	info: Adding group `auditors' (GID 1003) ...
```
#### пользователя logger с домашней директорией /opt/logger 
```
sudo useradd -m -d /opt/logger logger
```

#### без возможности входа в систему

```
sudo vim /etc/passwd

logger:x:1001:1004::/opt/logger::/bin/bash
меняем на 
logger:x:1001:1004::/opt/logger:/usr/sbin/nologin
```

#### Разрешить с помощью ACL:
инициализация
```
mkdir uploads
# права на папку
getfacl uploads

	# file: uploads
	# owner: alrex
	# group: alrex
	user::rwx
	group::rwx
	other::r-x
```


пользователю www-data чтение всех файлов
```
setfacl -m u:www-data:rX uploads/

# права на папку
getfacl uploads

# user:www-data:r-x
```


группе ftpusers запись в uploads
```
# Права на запись и соответственно чтение для ftpusers
setfacl -m g:ftpusers:rwX uploads/

getfacl uploads
#  group:ftpusers:rwx
```

группе admins полный доступ
```
setfacl -m g:admins:rwxX uploads/

getfacl uploads                 
# group:admins:rwx	
```

### app.log

```bash
getfacl var/www/server-app/app.log

# file: var/www/server-app/app.log
# owner: root
# group: root
user::rw-
group::r--
other::r--
```


пользователю logger полный доступ только к файлу app.log
```
sudo setfacl -m u:logger:rwxX /var/www/server-app/app.log
```

группе auditors чтение файла app.log
```
sudo setfacl -m g:auditors:rX /var/www/server-app/app.log
```
Результат
```
getfacl /var/www/server-app/app.log

# file: var/www/server-app/app.log
# owner: root
# group: root
user::rw-
user:logger:rwx
group::r--
group:auditors:r-x
mask::rwx
other::r--
```


## umask

Получим начальное значение
```
umask
# 0002
```

Настроить систему так, чтобы новые файлы создавались с правами rw-r-----, а директории - rwxr-x---

Для директории надо получить
rwxr-x--- (750)   
777-750 = 027
файл 
rw-r----- (640)
666-640 = 026
Установим и проверим

```
umask 027 & rm mydir/file & rm -r mydir/u1
touch mydir/file & mkdir mydir/u1 & ls -l mydir/

026
-rw-r----- 1 alrex alrex    0 Jul  2 08:38 file
drwxr-x--x 2 alrex alrex 4096 Jul  2 08:38 u1


027
-rw-r----- 1 alrex alrex    0 Jul  2 08:24 file
drwxr-x--- 2 alrex alrex 4096 Jul  2 08:24 u1

```
Все *OK*, но работает только на `027` 

Important

не забудьте восстановить исходное состояние системы после проверки

Вернём назад

```
umask 0002
ls -l mydir/

-rw-rw-r-- 1 alrex alrex    0 Jul  2 08:29 file
drwxrwxr-x 2 alrex alrex 4096 Jul  2 08:29 u1

```


## SU



Разрешить пользователю logger вход в систему; 
```
sudo vim /etc/passwd


 
logger:x:1001:1004::/opt/logger:/usr/sbin/nologin
меняем на
logger:x:1001:1004::/opt/logger::/bin/bash
```

переключиться на него с помощью su, 
```
su logger
# passwd =
```
сохранив текущее окружение и создать файл /tmp/logger-envs и вывести в него переменные окружения. 
```
env > /tmp/logger-envs

```

Выйти и переключиться еще раз с -; 
```
exit
su - logger
# переклюился ка вошёл под пользователем
#logger@ubuntu1:~$
```
сравнить вывод env и содержимое файла /tmp/logger-envs

Первый вариант содержит строки подключения по SSH
```
SSH_CONNECTION=192.168.50.108 58228 192.168.50.34 1234
SSH_CLIENT=192.168.50.108 58228 1234

Во 2 варианте этого нет

И разница в домашних директориях

PWD=/home/alrex/Homework/DevopsHomeWorks/10 Unix утилиты 1/practice

2 вариант
PWD=/opt/logger

```

Без переключения пользователя создать от имени logger директорию /tmp/logger-dir

```
mkdir /tmp/logger-dir
```

## Анализ производительности
Warning

будьте осторожны, при выполнении можно неслабо "приложить" машину

Определите текущую load average; установить пакет sysstat
```
sudo apt upgrade
sudo apt install sysstat
sudo apt install stress-ng
sudo apt install dstat
```
Запустить стресс-тест с помощью утилиты stress-ng:
stress-ng --cpu 4 --timeout 600
stress-ng --vm 2 --vm-bytes 2G --timeout 300 &
stress-ng --vm 1 --vm-bytes 1G --timeout 300 -s 1


Понаблюдать за тем что показывают утилиты
dstat -cglmns --top-cpu --top-mem --top-io

при запуске 
```
stress-ng --vm 2 --vm-bytes 2G --timeout 300 &
stress-ng --vm 1 --vm-bytes 1G --timeout 300 -s 1
```
Показывает наиболее дорогие
![image](https://github.com/user-attachments/assets/e8c4ae32-b18f-4eba-9d01-c645bcc7c448)
При `stress-ng --cpu 4 --timeout 600`
![image](https://github.com/user-attachments/assets/78ca49cf-b62a-40d9-a315-9952a2c3bb84)


mpstat -P ALL
Не показал изменеий


Запустить dd if=/dev/zero of=/tmp/testfile bs=1M count=500 
и параллельно с помощью iostat найти
устройство с максимальной нагрузкой

%util диска
await (среднее время ожидания)
Самостоятельно изучить такие утилиты как atop и sar; сгенерировать нагрузку с помощью stress-ng и dd и проанализировать постфактум с помощью atop и sar (то есть условно 5 минут понагружали, сняли нагрузку и анализируем что там было)
Запустить openssl speed -seconds 30 2>& 1 > /dev/null & и с помощью pidstat найти
PID процесса openssl
% пользовательского (usr) и системного (sys) CPU time
Запустить sleep 5; ls -R /usr и после ее завершения найти
время выполнения (real, user, sys)
максимальное потребление памяти
Запустить стресс-тест с помощью утилиты stress-ng (параметры подобрать самостоятельно) и вывести с помощью ps топ-5 процессов (по очереди) с наибольшим потреблением
CPU
DISK
MEM
