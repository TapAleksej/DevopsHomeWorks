
```bash
# установим
sudo apt install nodejs
```
### Создам файл для запуска в сервисе

Создам и скопирую в файл `/usr/local/www/myapp/index.js` скрипт из задания

```js
const http = require('http');
// Get MYAPP_PORT from environment variable
const MYAPP_PORT = process.env.MYAPP_PORT;
http.createServer((req, res) => {
if (req.url === '/kill') {
// App die on uncaught error and print stack trace to stderr
throw new Error('Someone kills me');
}
if (req.method === 'POST') {
// App print this message to stderr, but is still alive
console.error(`Error: Request ${req.method} ${req.url}`);
res.writeHead(405, { 'Content-Type': 'text/plain' });
res.end('405 Method Not Allowed');
return;
}
// App print this message to stdout
console.log(`Request ${req.method} ${req.url}`);
res.writeHead(200, { 'Content-Type': 'text/plain' });
res.end('200 OK');
})
.listen(MYAPP_PORT);
```



#### Запуск руками скрипта
```bash
MYAPP_PORT=3000 node index.js
```

Проверю работу
```bash
alrex@ubuntu1:~/Homework/pro$ curl localhost:3000
200 OK

alrex@ubuntu1:~/Homework/pro$ curl -X POST localhost:3000
405 Method Not Allowed

# совершим умбивство
alrex@ubuntu1:~/Homework/pro$ curl 'http://localhost:3000/kill'
curl: (52) Empty reply from server
```

## Создание сервиса myapp

```
sudo touch /etc/systemd/system/myapp.service
sudo vim /etc/systemd/system/myapp.service
```
#### Содержимое `myapp.service`

```bash
[Install]
WantedBy=multi-user.target

[Service]
Environment=MYAPP_PORT=3000
User=www-data
Group=www-data
ExecStart=/usr/bin/node /usr/local/www/myapp/index.js
Restart=always
# Отправка логов syslog
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=myapp
```
где `/usr/bin/node` - где установлен nodejs, получил командой `which node`



#### Запуск и проверка сервиса

ПереЧИТАЕМ сервисы и запустим свой
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
он возродился из за `Restart=always` в файле `/etc/systemd/system/myapp.service`
```bash
alrex@ubuntu1:~/Homework/pro$ sudo systemctl status myapp

● myapp.service
     Loaded: loaded (/etc/systemd/system/myapp.service; static)
     Active: active (running) since Mon 2025-06-16 12:41:28 UTC; 12s ago
   Main PID: 36632 (node)
      Tasks: 10 (limit: 3735)
```

## Логирование

#### Файл для настройки логгирования
```bash
sudo touch /etc/rsyslog.d/100-myapp.conf
sudo vim /etc/rsyslog.d/100-myapp.conf
```
Содержимое 100-myapp.conf
```bash
$RepeatedMsgReduction off
if $programname == 'myapp' and $syslogseverity < 5 then  -/var/log/myapp/error.log
if $programname == 'myapp' and $syslogseverity >= 5 then  -/var/log/myapp/debug.log
```

#### Создание и выдача прав для лог файлов

```
sudo touch /var/log/myapp/error.log
sudo touch /var/log/myapp/debug.log

# даём права на запись в логи
sudo chown www-data:www-data /var/log/myapp/error.log
sudo chown www-data:www-data /var/log/myapp/debug.log
```

#### Ротация логов
Создаём файл `sudo nano /etc/logrotate.d/myapp` c текстом
```bash
/var/log/myapp/debug.log
/var/log/myapp/error.log {
rotate 7
daily
compress
missingok
notifempt
postrotate
invoke-rc.d rsyslog rotate > /dev/null
endscript
}
```




##  Проверяем сервис

Видно запущен `Active: active` , но запуска `myapp.service; disabled` после перезагрузки автоматом не будет
```bash
sudo systemctl status myapp
● myapp.service
     Loaded: loaded (/etc/systemd/system/myapp.service; disabled; pres>
     Active: active (running) since Wed 2025-06-18 10:21:28 UTC;
```
Включаю автозапуск
```bash
sudo systemctl enable myapp
# myapp.service; enabled
```

Посмотреть лог моего сервиса
```bash
tail -f /var/log/myapp/debug.log
tail -f /var/log/myapp/error.log
sudo journalctl -u myapp.service
```



