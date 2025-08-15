Написать роль (роли?) для развертывания приложения
https://gitlab.com/devops201206/visits НЕ в docker

Решение на  https://github.com/TapAleksej/deploy_app

```bash
mkdir DEPOLY_APP
mkdir GITREPO
cd DEPOLY_APP
ansible-galaxy init deploy_app
```
hosts
```
[target]
10.129.0.23
```
ansible.cfg
```
[defaults]
remote_user = ansible
host_key_checking = False
private_key_file = /home/ansible/.ssh/id_ed25519
```

run.yml
```yml
---
- hosts: all
  become: true
  roles:
    - ./deploy_visits
```

```
### Tasks

#### main.yml
```
---
- include_tasks: clone_repogit.yml
- include_tasks: prepare.yml
- include_tasks: install_postgres.yml
- include_tasks: create_db.yml
- include_tasks: install_redis.yml
- include_tasks: execute_app.yml
- include_tasks: start_service.yml
```

#### clone_repogit.yml
```yml
---
- name: check present git in remote hosts
  command:  git --version
  register: git_data
  ignore_errors: yes

- name: if exists git then print mesage
  debug:
    msg: "{{ git_data.stdout }} on {{ inventory_hostname }} is installed"
  when:  git_data.rc == 0

- name: if not exists git then print mesage
  debug:
    msg: "git  on {{ inventory_hostname }} is not installed"
  when:  git_data.rc != 0

- name: Check if app folder exists
  become: true
  file:
    path: "{{ prj_dir }}"
    state: directory

- name: git repo clone
  git:
    repo: 'https://gitlab.com/devops201206/visits.git'
    dest: "{{ prj_dir }}"

- name: copy env
  template:
    src: env_file.j2
    dest: "{{ prj_dir }}/.env"


```

#### Необходимые компоненты
`tasks/prepare.yml`
```yml
---
- name: install packages
  package:
    name:
      - gnupg2
      - python3-psycopg2
      - acl
    update_cache: yes

- name: Install deps
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - python3-venv
    - python3-pip
```




#### install_postgres.yml
```yml
---
- name: Update apt cache
  apt:
    update_cache: yes

- name: Add postgres key
  apt_key:
    url: "https://www.postgresql.org/media/keys/ACCC4CF8.asc"
    state: present

- name: Add postgres repo
  apt_repository:
    state: present
    repo: "deb https://apt.postgresql.org/pub/repos/apt {{ ansible_distribution_release }}-pgdg main"
    filename: postgresql

- name: Install postgres
  apt:
    name: postgresql-{{ postgres_version }}
    state: present


- name: Ensure PostgreSQL is running and enabled
  service:
    name: postgresql
    state: started
    enabled: yes


# create tmp directory - need for create user in postgre
- name: Create Ansible remote temporary directory
  become: yes
  file:
    path: "{{ ansible_remote_tmp_dir }}"
    state: directory
    owner: root
    group: root
    mode: "{{ ansible_remote_tmp_mode }}"

```



#### Инициализировать БД. 
Для этого


Переключиться на пользователя postgres
sudo -u postgres psql
sudo su - postgres
psql
Создать БД

CREATE DATABASE visits_db;
CREATE USER visitsuser WITH PASSWORD 'visitspass';
GRANT ALL PRIVILEGES ON DATABASE visits_db TO app_user;

Создать таблицу

CREATE TABLE IF NOT EXISTS visits (id SERIAL PRIMARY KEY, timestamp TIMESTAMP DEFAULT NOW());
exit;
\c visits_db;

https://docs.ansible.com/ansible/latest/collections/community/postgresql/postgresql_privs_module.html#ansible-collections-community-postgresql-postgresql-privs-module

#### tasks/create_bd
```yml
---
- name: Create db
  become: true
  become_user: postgres
  postgresql_db:
    name: "{{ db_name }}"
    owner: "{{ db_user }}"

- name: Grant db user access to app db
  become: true
  become_user: postgres
  postgresql_privs:
    type: database
    database: "{{ db_name }}"
    roles: "{{ db_user }}"
    grant_option: yes
    privs: all
    state: present


- name: Create table visits (id SERIAL PRIMARY KEY, timestamp TIMESTAMP DEFAULT NOW())
  postgresql_query:
    db: "{{ db_name }}"
    login_user: "{{ db_user }}"
    login_password: "{{ postgres_password }}"
    login_host: "{{ login_host }}"
    login_port: "{{ db_port }}"
    query: |
         CREATE TABLE IF NOT EXISTS visits (
            id SERIAL PRIMARY KEY,
            timestamp TIMESTAMP DEFAULT NOW()
          );
```

#### install_redis.yml
```yml
---
- name: Ensure Redis is present
  apt:
    name: redis-server
    state: latest

- name: Ensure Redis is started
  become: true
  service:
    name: redis-server
    state: started
    enabled: yes

- name: Ensure Redis Configuration
  become: true
  template:
    src: redis.conf.j2
    dest: /etc/redis/redis.conf
    owner: root
    group: root
    mode: '0644'
 
- name: Restart Redis
  service:
    name: redis-server
    state: restarted

```
#### execute_app.yml
```yml
---


# Python
- name: Create venv
  command: python3 -m venv "{{ prj_dir }}/.venv"
  args:
    creates: "{{ prj_dir }}/.venv"


- name: Install requiments
  pip:
    name: "{{ item }}"
    virtualenv: "{{ prj_dir }}/.venv"
    state: present
  loop:
    - flask
    - redis
    - psycopg2-binary
    - dotenv

 # change file
- name: Insert into app.py after import os
  blockinfile:
    path: "{{ prj_dir }}/app.py"
    block: |
      from dotenv import load_dotenv
      load_dotenv(dotenv_path='./.env')
    insertafter: "^import os"
    create: yes


```
#### start_service.yml
```yml
---
# service syste
- name: Create visit service
  template:
    src: myapp.service.j2
    dest: /etc/systemd/system/visit.service

- name: Reload systemd
  systemd_service:
    daemon_reload: true

- name: Start myapp
  systemd_service:
    name: visit.service
    state: started
    enabled: true

```

### vars

main.yml
```
---
# vars file for deploy_visits
db_user: app_user
db_name: visits_db
db_port: 5432
postgres_password: visitspass
postgres_version: 17
login_host: localhost
prj_dir: /home/ansible/Visit
#full_access_role_name: admin
redis_port: 6379
redis_bind: "127.0.0.1"
redis_password: "visitspass"
redis_logfile: "/var/log/redis/redis.log"
redis_maxmemory: "1gb"
redis_maxmemory_policy: "allkeys-lru"
redis_dbfilename: "dump.rdb"
redis_dir: "/var/lib/redis"
redis_appendonly: "yes"
redis_appendfilename: "appendonly.aof"
redis_appendfsync: "everysec"
ansible_remote_tmp_dir: "/var/lib/postgresql/.ansible/tmp"
ansible_remote_tmp_mode: "1777"

```

Шифруем vars
```
ansible-vault encrypt vars/main.yml
```


Запуск

```
sudo su ansible
ansible-playbook -i hosts run.yml --diff --ask-vault-pass
```


## проверка на slave

curl 127.0.0.1:5000/visits

```
{
"source": "database",
"visits": 2
}
```

```
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://10.129.0.23:5000
Press CTRL+C to quit
127.0.0.1 - - [12/Aug/2025 08:41:37] "GET / HTTP/1.1" 404 -
127.0.0.1 - - [12/Aug/2025 08:41:59] "GET /visits HTTP/1.1" 200 -

```