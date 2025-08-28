https://github.com/TapAleksej/Docker-compose/tree/main/Metrics%20app

## Metrics app
### Задание
[compose-apps/golang-app\_01 · main · dos-29-onl / docker-apps · GitLab](https://gitlab.com/dos-29-onl/docker-apps/-/tree/main/compose-apps/golang-app_01?ref_type=heads)
Веб-приложение на Go, которое предоставляет API эндпоинты, собирает метрики в формате Prometheus и сохраняет логи запросов в PostgreSQL.

Требования
1. Golang 1.24.4
2. Postgresql

Запуск приложения
Перед запуском приложения должна быть инициализирована БД:
```bash
CREATE USER goappuser WITH PASSWORD 'qwer/.,m';
CREATE DATABASE goapp OWNER goappuser;
```



```
ls -a
.  ..  .env  compose.yml  golang-app_01
```

compose.yml
```
services:
  database:
    image: postgres:17
    restart: always
    volumes:
      - pg_data:/var/lib/postgresql/data
    environment:
          POSTGRES_USER: "${POSTGRES_USER}"
          POSTGRES_PASSWORD: "${POSTGRES_PASSWORD}"
          POSTGRES_DB: "${POSTGRES_DB}"
    healthcheck:
      test: ["CMD-SHELL", "sh -c 'pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}'"]
      interval: 10s
      timeout: 5s
      retries: 5


  app:
    build:
      context: ./golang-app_01
      dockerfile: Dockerfile
    ports:
      - 5000:5000
    env_file:
      - ./golang-app_01/.env_app
    restart: always
    depends_on:
      database:
        condition: service_healthy

volumes:
  pg_data:

```
.env
```
POSTGRES_USER=goappuser
POSTGRES_PASSWORD='qwer/.,m'
POSTGRES_DB=goapp
POSTGRES_HOST=database
POSTGRES_PORT=5432
```
.env_app
```
PG_HOST=database
PG_PORT=5432
PG_USER=goappuser
PG_PASSWORD='qwer/.,m'
PG_DATABASE=goapp
```

dockerfile
```
FROM  golang:1.24-alpine
WORKDIR app/
COPY . .

RUN go build -o myapp .

ENTRYPOINT  ["./myapp"]
```


### Запуск

```
docker compose up -d
```


```
psql -U goappuser -W goapp
Password: 
psql (17.6 (Debian 17.6-1.pgdg13+1))
Type "help" for help.

goapp=# \l
                                                      List of databases
   Name    |   Owner   | Encoding | Locale Provider |  Collate   |   Ctype    | Locale | ICU Rules |    Access privileges    
-----------+-----------+----------+-----------------+------------+------------+--------+-----------+-------------------------
 goapp     | goappuser | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           | 
 postgres  | goappuser | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           | 
 template0 | goappuser | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           | =c/goappuser           +
           |           |          |                 |            |            |        |           | goappuser=CTc/goappuser
 template1 | goappuser | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           | =c/goappuser           +
           |           |          |  
```


```
docker compose ps
NAME             IMAGE         COMMAND                  SERVICE    CREATED          STATUS                          PORTS
go1-app-1        go1-app       "./myapp"                app        59 minutes ago   Restarting (2) 56 seconds ago   
go1-database-1   postgres:17   "docker-entrypoint.s…"   database   59 minutes ago   Up 59 minutes (healthy)         5432/tcp
```




```
curl "http://localhost:5000/generate-load?n=5000000"
Load generated with 5000000 iterations

curl http://localhost:5000/metrics

# HELP go_gc_duration_seconds A summary of the wall-time pause (stop-the-world) duration in garbage collection cycles.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 2.1726e-05
go_gc_duration_seconds{quantile="0.25"} 2.1726e-05
go_gc_duration_seconds{quantile="0.5"} 2.1726e-05
go_gc_duration_seconds{quantile="0.75"} 2.1726e-05
go_gc_duration_seconds{quantile="1"} 2.1726e-05
go_gc_duration_seconds_sum 2.1726e-05
go_gc_duration_seconds_count 1
# HELP go_gc_gogc_percent Heap size target percentage configured by the user, otherwise 100. This value is set by the GOGC environment variable, and the runtime/debug.SetGCPercent function. Sourced from /gc/gogc:percent.
# TYPE go_gc_gogc_percent gauge

url http://localhost:5000/error
Server Error

curl http://localhost:5000
Main Page


```