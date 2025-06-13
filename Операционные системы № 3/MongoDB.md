# MongoDB
#### бд в которой нет таблиц, а есть коллекции

### Задание 1
установить MongoDB.
создать таб лицу data; создать пользователя manager , у которого будет доступ
только на чтение этой таб лицы.

```bash
sudo apt install gnupg curl
```
Добавить репозиторий в список источников APT:

```bash
alrex@ubuntu1:~$ curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor

alrex@ubuntu1:~$ echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ]
https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse
# (это для 22.04 Jammy)


alrex@ubuntu1:~$ sudo apt-get update

Hit:1 http://ru.archive.ubuntu.com/ubuntu noble InRelease
Hit:2 http://security.ubuntu.com/ubuntu noble-security InRelease
Hit:3 http://ru.archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:4 http://ru.archive.ubuntu.com/ubuntu noble-backports InRelease
Ign:6 https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/7.0 InRelease
Get:7 https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 InRelease [3,005 B]
********

# sudo apt-get install -y mongodb-org

alrex@ubuntu1:~$ sudo apt-get install -y mongodb-org
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  mongodb-database-tools mongodb-mongosh mongodb-org-database mongodb-org-database-tools-extra
  mongodb-org-mongos mongodb-org-server mongodb-org-shell mongodb-org-tools
The following NEW packages will be installed:
  mongodb-database-tools mongodb-mongosh mongodb-org mongodb-org-database
  mongodb-org-database-tools-extra mongodb-org-mongos mongodb-org-server mongodb-org-shell
  mongodb-org-tools

alrex@ubuntu1:~$ sudo systemctl start mongod
alrex@ubuntu1:~$ sudo systemctl status  mongod
● mongod.service - MongoDB Database Server
     Loaded: loaded (/usr/lib/systemd/system/mongod.service; disabled; preset: enabled)
     Active: active (running) since Thu 2025-06-12 11:08:35 UTC; 15s ago
       Docs: https://docs.mongodb.org/manual
	*********************
# брандмауер
alrex@ubuntu1:~$ sudo ufw allow 27017
Rules updated
Rules updated (v6)

#Подключитесь к MongoDB
alrex@ubuntu1:~$ mongosh
Current Mongosh Log ID: 684ab578225398473e69e327
Connecting to:          mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.5.2
Using MongoDB:          8.0.10
Using Mongosh:          2.5.2
**************

# Проверка тестовым запросом
test> db.runCommand({ ping: 1 })
{ ok: 1 }


```
Установка произведена


Не хочу портить бд существующие, поэтому создам отдельную базу mydb с таблицей (коллекцией) data

```bash
test> use mybd
switched to db mybd
mybd> db.createCollection("data")
{ ok: 1 }
# покажи что есть из таблиц
mybd> show collections
data
mybd>

```
Создание роли только на чтение для коллекции data
```bash
db.createRole({
  role: "readDataOnly",
  privileges: [
    {
      resource: { db: "mybd", collection: "data" },
      actions: ["find"]
    }
  ],
  roles: []
})
```
СОздание пользователя  с этой ролью
```bash
db.createUser({
  user: "manager",
  pwd: "man",
  roles: [
    { role: "readDataOnly", db: "myDatabase" }
  ]
})
# { ok: 1 }

```
Включаем авторизацию
```bash
alrex@ubuntu1:~$ sudo nano /etc/mongod.conf
# изменим
security:
  authorization: enabled

alrex@ubuntu1:~$ sudo systemctl restart mongod
alrex@ubuntu1:~$ sudo systemctl status mongod

```
