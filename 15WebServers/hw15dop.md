*Все файлы на гитхабе 15WebServers/scripts/*

## Запустить на ВМ как systemd сервис приложение на python

### Занимаемся python

```bash
sudo mkdir /opt/testapp
sudo vim /opt/testapp/myapp.py
```
запущен ли питон
```
ps aux | grep python

#  /usr/bin/python3  в списке есть  - запущен
```

Нужно работать под www-data -дам права
```
sudo chown -R www-data:www-data /opt/testapp/
```

Создаём виртуальное окружение для питон проекта
```
cd /opt/testapp/
python3 -m venv .venv
```

Активируем виртуальное окружение
```
source /opt/testapp/.venv/bin/activate

# пакеты какие установлены
pip list

 pip install flask
```

Запустил ручками - работает
```
/opt/testapp/.venv/bin/python3.12 /opt/testapp/myapp.py

 * Serving Flask app 'myapp'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:8000
 * Running on http://192.168.50.34:8000
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 119-271-916

```
### Сервис

посмотрим какие есть сервисы, чтобы не назвать его так же
```
sudo ls /etc/systemd/system/ | grep -E "service$"
ls /etc/systemd/system/ | grep test  testnginx.service
```

Создадим unit file
```bash
sudo vim /etc/systemd/system/testnginx.service
```

```
[Unit]
Description=Test
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/opt/testapp
ExecStart=/opt/testapp/.venv/bin/python3 /opt/testapp/myapp.py
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=testnginx
Environment=MYAPP_PORT=8000

[Install]
WantedBy=multi-user.target
```


Запустим и проверим - много лишнего - но для памяти лучше повторить
```bash
# общий рестарт nginx
sudo nginx -t
sudo nginx -s reload
sudo systemctl status nginx

# рестарт своего юнита
sudo systemctl daemon-reload

sudo systemctl stop testnginx.service
sudo systemctl restart testnginx.service 
sudo systemctl status testnginx.service 
# sudo systemctl disable testnginx.service
ps aux | grep testnginx 
sudo netstat -tulnp
```


### Создать директорию /var/www/static, в ней создать файлы

```bash
sudo mkdir /var/www/static
sudo vim /var/www/static/index.html
```

```bash
sudo vim /var/www/static/style.js
```


### Скачать лого nginx:

```bash
sudo wget -O /var/www/static/nginx-logo.png https://nginx.org/nginx.png

```
Права - и  обязательно на ЗАПУСК!!
```
sudo chown -R www-data:www-data /var/www/static/
sudo chmod +x /var/www/static/

```


### Настроить Nginx в качестве прокси для созданного в пп1,2 приложения

nginx проксирует запросы на flask-бэкенд
nginx раздает статические файлы из директории /var/www/static

Итог работы выглядит так: видео

```bash
sudo vim /etc/nginx/sites-available/testnginx
```

```
server {
        listen 80;
        listen [::]:80;

        access_log /var/log/nginx/test_access.log;
        error_log /var/log/nginx/test_error.log;

        server_name tms.by www.tms.by;


        location /static {
                alias /var/www/static;
                expires 30d;
                access_log off;
                add_header Cache-Control "public";
                }


        location / {
                proxy_pass http://localhost:8000;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                }
}

```
```
sudo ln -sf /etc/nginx/sites-available/testnginx /etc/nginx/sites-enabled
```

Рестартуем службу
Запустим и проверим
```bash
# общий рестарт nginx
sudo nginx -s reload

sudo nginx -t

sudo systemctl restart nginx
sudo systemctl status nginx


# перчитаем свой юнит
# sudo systemctl daemon-reload

# sudo systemctl stop testnginx.service
sudo systemctl restart testnginx.service 
sudo systemctl status testnginx.service 
```

### Проверка
```
curl -I http://tms.by

HTTP/1.1 200 OK
Server: nginx/1.24.0 (Ubuntu)
Date: Sun, 20 Jul 2025 15:46:05 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 653
Connection: keep-alive




curl -I http://tms.by/static/nginx-logo.png

HTTP/1.1 200 OK
Server: nginx/1.24.0 (Ubuntu)
Date: Sun, 20 Jul 2025 15:43:57 GMT
Content-Type: image/png
Content-Length: 2103
Last-Modified: Thu, 02 Oct 2014 14:54:03 GMT
Connection: keep-alive
ETag: "542d670b-837"
Expires: Tue, 19 Aug 2025 15:43:57 GMT
Cache-Control: max-age=2592000
Cache-Control: public
Accept-Ranges: bytes

```