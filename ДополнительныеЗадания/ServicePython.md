Команда anestesia.tech написала приложение на python, которое представляет собой трехкомпонентную систему для логирования, тестирования и анализа веб-приложений. Репозиторий проекта находится по ссылке -> log-analize-python. В репозитории имеется описание проекта, в тч как каждый из компонентов запускается. Вам необходимо развернуть эту систему в соответствии с требованиями:

Операционная система - Ubuntu 20.04+ / Debian 11+
Python 3.11+
Присутствует виртуальное окружение (python virtualenv)
Установлены пакеты libpq-dev build-essential
Корневая директория проекта - /opt/web_monitoring
API-сервер (log-server.py) и дашборд запущены с помощью systemd
Для запуска скрипта генерации нагрузки можно использовать
обычный ручной запуск
bash-скрипт (в тч однострочник) как обертка
cron для запуска по расписанию (ставьте небольшой промежуток, чтобы проверить и не забывайте убирать после успешной отработки)
systemd сервис типа oneshot
Запуск от имени пользователя www-data
После запуска необходимо проверить работоспособность всех компонентов

# Решение
Делаю к себе `fork` репозитария `https://github.com/AnastasiyaGapochkina01/log-analize-python`

### Действия на `ssh alrex@192.168.50.34 -p 1234`:
Папку web_monitoring
`git init`
'git clone git@github.com:TapAleksej/log-analize-python.git'

Ставлю недостающий для создания виртуального окружени на python компонент
`sudo apt install python3.12-venv`

Проверка версии питона
```
python3 --version
Python 3.12.3
```


Создаю виртуальное окружение для пакетов
`sudo -u www-data python3 -m venv /opt/web_monitoring/.venv`

Активирую окружение
`source .venv/bin/activate`

В него загружаю пакеты из requirements.txt
`sudo -u www-data /opt/web_monitoring/.venv/bin/pip install -U -r requirements.txt`

#### проблемное место
После установки пакетов начинаю долго "плавать" с правами
`sudo chown www-data:www-data /opt/web_monitoring/`
Добавил на права запись
`sudo chmod g+w www-data:www-data /opt/web_monitoring/*`

и на запуск добавил права
`sudo chmod x /opt/web_monitoring/*`

*но должен был создастся файл info_app.log*
```
ls -ld /opt/web_monitoring
sudo chgrp alrex /opt/web_monitoring
```
Только добавления в группу моей учетки alrex получилось запустить.

## Запуск log-server
```bash
(.venv) alrex@ubuntu1:/opt/web_monitoring$ python log-server.py
INFO:     Started server process [12708]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:9100 (Press CTRL+C to quit)
INFO:     127.0.0.1:43294 - "GET / HTTP/1.1" 200 OK
```

Отправляем курлы
```bash
curl http://localhost:9100
```

Слушаем журнал и получаем логи info_app
```bash
alrex@ubuntu1:/opt/web_monitoring$ tail -f info_app.log
2025-06-22 11:22:52 - INFO - GET / from 127.0.0.1 - Status: 200 - 0.007s
2025-06-22 11:24:07 - INFO - GET / from 127.0.0.1 - Status: 200 - 0.0013s
2025-06-22 11:32:46 - INFO - GET / from 192.168.50.34 - Status: 200 - 0.016s
```

## Запуск генератора
```bash
(.venv) alrex@ubuntu1:/opt/web_monitoring$ python load-generator.py http://localhost:9100 -r 1000 -c 50

==================================================
🛠️ Settings:
  Target URL: http://localhost:9100
  Total requests: 1000
  Parallel requests: 50
==================================================


📊 Load testing results:
✅ Successful requests: 0 (0.0%)
❌ Failure requests: 1000 (100.0%)
⏱️ Total time: 68.03 s
⚡ Requests per second: 14.70
⏳ Average response time: 0.0680 s
```
При этом создался файл `results.csv` с данными

## Запуск дашборда

```bash
(.venv) alrex@ubuntu1:/opt/web_monitoring$ python3 dashboard.py
 * Serving Flask app 'dashboard'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://192.168.50.34:5000
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 402-792-911
```
И в браузере получаем по адресу
`http://192.168.50.34:5000` дашбоард


# Systemd
Создание API-сервера (log-server.py)
`sudo vim /etc/systemd/system/apilog.service`

Запустилось только под alrex

```bash
[Unit]
Description=API Log Server
After=network.target

[Service]
Type=simple
User=alrex
Group=alrex
WorkingDirectory=/opt/web_monitoring
ExecStart=/opt/web_monitoring/.venv/bin/python3.12 /opt/web_monitoring/log-server.py
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=apilog
Environment=MYAPP_PORT=9100

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl daemon-reload
sudo systemctl status rsyslog
sudo systemctl start apilog
sudo systemctl status apilog
journalctl -t apilog

sudo systemctl enable apilog
```
проверка `curl http://localhost:9100`

Работает
```
$ tail -f info_app.log
2025-06-22 14:14:07 - INFO - GET / from 127.0.0.1 - Status: 200 - 0.0046s
2025-06-22 14:14:23 - INFO - GET / from 127.0.0.1 - Status: 200 - 0.0008s
``