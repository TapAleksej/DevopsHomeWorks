# Express Memcached Demo
Приложение предоставляет API endpoint, который записывает данные в Memcached и сразу же читает их обратно, демонстрируя работу с кэшированием. Каждый запрос сохраняет текущую метку времени в кэше и возвращает ее в ответе.

## Требования
1) Node.js не ниже 12
2) Memcached сервер
3) Nginx в роли reverse proxy

## Запуск приложения
```bash
npm install
npm start
```
## Проверка
```bash
curl http://localhost:3000
```
Пример ответа
```json
{
  "message": "Данные успешно записаны и прочитаны из Memcached!",
  "cached": {
    "timestamp": 1640995200000
  },
  "status": "success"
}
```

# Реализация

https://github.com/TapAleksej/Docker-compose/tree/main/nodejs_01

.dockerignore
```
nginx.conf
Dockerfile
.env
README.md
compose.yml
```

.env
```
MEMCACHED_HOST=memcached
```

nginx.conf
```
server {
    listen 80;

    location / {
        proxy_pass http://app:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Dockerfile
```
FROM node:alpine
WORKDIR /app
COPY . .
RUN npm install

ENTRYPOINT ["sh", "-c", "npm run start"]
```

compose.yml
```
services:
  # Контейнер с Node.js и app
  app:
    build:
      context: .    
    environment:
      MEMCACHED_HOST: "${MEMCACHED_HOST}"   
    depends_on:
      - memcached
    restart: always    

  # Контейнер с базой данных
  memcached:
    image: memcached:alpine
    ports:
      - '11211:11211'  
    restart: always 

  # Контейнер с nginx
  nginx:
    container_name: proxy_nginx
    depends_on:
      - app    
    image: nginx:latest
    ports:
      - '80:80'
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    restart: always
```

```
curl 127.0.0.1
{"message":"Данные успешно записаны и прочитаны из Memcached!",
"cached":{"timestamp":1756370013709},"status":"success"}
```