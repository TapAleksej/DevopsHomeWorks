### Задача
https://gitlab.com/dos-29-onl/docker-apps#

Flask-микросервис
Приложение работает в standalone режиме. То есть никаких дополнительных контейнеров ему не нужно. Требуются environments.
Проверка осуществляется командой

curl http://localhost:5000/config

requirements.txt
```
flask
gunicorn
```

```python
# app.py
import os
from flask import Flask, jsonify

app = Flask(__name__)
app.config['API_VERSION'] = os.getenv('API_VERSION', 'v1')
app.config['DEBUG_MODE'] = os.getenv('DEBUG_MODE', 'false').lower() == 'true'

@app.route('/config')
def config():
    return jsonify({
        'api_version': app.config['API_VERSION'],
        'debug': app.config['DEBUG_MODE'],
        'environment': os.getenv('APP_ENV', 'development')
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.getenv('PORT', 5000)))

```

### Реализация
vim Dockerfile

```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y python3 python3-pip
WORKDIR /apps
COPY . .
RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["python3", "app.py","--host", "0.0.0.0","--port", "5000"]
```

```
docker build -t img:v1 .

# добавим окружение environment

docker run -dit --name cont -e API_VERSION=v1  -e DEBUG_MODE=true \
-e APP_ENV='development' -e PORT='5000' -p 5000:5000 img:v1 
```

```
docker logs cont

 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://172.17.0.2:5000
Press CTRL+C to quit

```

Проверка
```
curl http://localhost:5000/config
{"api_version":"v1","debug":true,"environment":"development"}
```