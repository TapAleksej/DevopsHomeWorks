
```
# установим
sudo apt install nodejs
```
## Создам файл для запуска в сервисе

Создам и скопирую в файл `/home/alrex/Homework/pro/index.js` скрипт из задания

Запуск руками скрипта
```
MYAPP_PORT=3000 node index.js
```

Проверю работу
```
alrex@ubuntu1:~/Homework/pro$ curl localhost:3000
200 OK

alrex@ubuntu1:~/Homework/pro$ curl -X POST localhost:3000
405 Method Not Allowed

# совершим умбивство
alrex@ubuntu1:~/Homework/pro$ curl 'http://localhost:3000/kill'
curl: (52) Empty reply from server
```

## Создам сервис myapp

```
sudo vim /etc/systemd/system/myapp.service
```
Минимально что нужно для запуска

```
[Service]
Environment=MYAPP_PORT=3000
ExecStart=/usr/bin/node /home/alrex/Homework/pro/index.js
```
где `/usr/bin/node` - где установлен nodejs, получил командой `which node`

#### Запуск и проверка

```
alrex@ubuntu1:~/Homework/pro$ sudo systemctl start myapp

# проверка
alrex@ubuntu1:~/Homework/pro$ sudo systemctl status myapp
● myapp.service
     Loaded: loaded (/etc/systemd/system/myapp.service; static)
     Active: active (running) since Mon 2025-06-16 12:05:35 UTC; 10s ago
   Main PID: 32202 (node)
      Tasks: 10 (limit: 3735)
     Memory: 12.0M (peak: 15.0M)
        CPU: 990ms
     CGroup: /system.slice/myapp.service
             └─32202 /usr/bin/node /home/alrex/Homework/pro/index.js

Jun 16 12:05:35 ubuntu1 systemd[1]: Started myapp.service.
```
Видно что сервис в режиме `active (running)`

Проверка прошла так же успешно но после
```bash
curl 'http://localhost:3000/kill'          curl 'http://localhost:3000/kill'
curl: (52) Empty reply from server
```

Статус стал `Active: failed (Result: exit-code) since Mon 2025-06-16 12>`


Для перезапуска добавим в app.service `Restart=always`
```bash
[Service]
Environment=MYAPP_PORT=3000
ExecStart=/usr/bin/node /home/alrex/Homework/pro/index.js
Restart=always
```
ПереЧИТАЕМ сервисы и запустим мой 
```bash
sudo systemctl daemon-reload

sudo systemctl start myapp

sudo systemctl status myapp
#  Active: active (running) since Mon 2025-06-16 12:32:09 UTC
```
проверим и убьём

```bash
curl -X POST localhost:3000
# 405 Method Not Allowed --- работает

alrex@ubuntu1:~/Homework/pro$ curl localhost:3000/kill
curl: (52) Empty reply from server
```
он возродился
```bash
alrex@ubuntu1:~/Homework/pro$ sudo systemctl status myapp

● myapp.service
     Loaded: loaded (/etc/systemd/system/myapp.service; static)
     Active: active (running) since Mon 2025-06-16 12:41:28 UTC; 12s ago
   Main PID: 36632 (node)
      Tasks: 10 (limit: 3735)
```

Посмотреть лог моего сервиса
```bash
journalctl -u myapp.service
```


