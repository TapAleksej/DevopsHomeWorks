# Написать роль для установки node-exporter НЕ в docker
https://ruvds.com/ru/helpcenter/kak-ustanovit-node-exporter/


wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz


sudo su ansible
ansible-playbook -i hosts run.yml --diff --ask-vault-pass

tasks

```
---
# user for node_exporter
- name: Create node_exporter user
  user:
    name: node_exporter
    system: yes
    shell: /sbin/nologin

- name: Force delete specific directory
  file:
    path: "{{ ansible_remote_tmp_dir }}"
    state: absent
    force: yes

# tasks file for node_exporter
- name: Create Ansible remote temporary directory
  become: yes
  file:
    path: "{{ ansible_remote_tmp_dir }}"
    state: directory
    owner: root
    group: root
    mode: "{{ ansible_remote_tmp_mode }}"

- name: get tar source from url
  get_url:
    url: "https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz"
    dest: "{{ ansible_remote_tmp_dir }}/node_exporter-1.9.1.linux-amd64.tar.gz"

- name: Extract tar
  unarchive:
    src:  "{{ ansible_remote_tmp_dir }}/{{ packet_name }}.tar.gz"
    dest: "/opt"
    remote_src: yes

- name: chown directory
  file:
    path: /opt/node_exporter
    owner: node_exporter
    group: node_exporter
    state: directory

- name: Force delete specific directory
  file:
    path: /opt/node_exporter
    state: absent
    force: yes


- name: Rename directory
  become: yes
  command: mv /opt/{{ packet_name }} /opt/node_exporter
  tags: rename

# sudo chown -R node_exporter:node_exporter /opt/node_exporter
- name: dir to node_exporter user
  become: yes
  file:
    path: "{{ node_exporter_path }}"
    recurse: yes
    state: directory
    owner: node_exporter
    group: node_exporter
    mode: "0755"


# service systemd
- name: Create  service
  template:
    src: node_exporter.service.j2
    dest: /etc/systemd/system/node_exporter.service

- name: Reload systemd
  systemd:
    daemon_reload: true

- name: Start node_exporter
  systemd:
    name: node_exporter
    state: restarted
    enabled: true
```
handler main.yml
```
---
# handlers file for node_exporter

- name: Restart node_exporter
  systemd:
    name: node_exporter
    state: restarted
    enabled: yes

- name: Daemon-reload
  systemd:
    daemon_reload: yes
```



templates/node_exporter.service.j2
```
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart= {{ node_exporter_path }}/{{ packet_name }}/node_exporter --collector.systemd

[Install]
WantedBy=multi-user.target

```

```
---
# vars file for node_exporter
prj_dir: /home/ansible/NODE_EXPORTER
ansible_remote_tmp_dir: "{{ prj_dir }}/tmp"
ansible_remote_tmp_mode: "1777"
node_exporter_path: /opt/node_exporter
packet_name: node_exporter-1.9.1.linux-amd64
```




Проверка

```

alrex@slv12:/opt$ sudo systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; preset: enabled)
     Active: active (running) since Thu 2025-08-14 12:57:48 UTC; 3s ago
   Main PID: 28632 (node_exporter)
      Tasks: 4 (limit: 1108)
     Memory: 2.5M (peak: 2.7M)
        CPU: 8ms
     CGroup: /system.slice/node_exporter.service
             └─28632 /opt/node_exporter/node_exporter --collector.systemd

Aug 14 12:57:48 slv12 node_exporter[28632]: time=2025-08-14T12:57:48.517Z level=INFO source=node_exporter.go:14>
Aug 14 12:57:48 slv12 node_exporter[28632]: time=2025-08-14T12:57:48.517Z level=INFO source=node_exporter.go:14>
Aug 14 12:57:48 slv12 node_exporter[28632]: time=2025-08-14T12:57:48.517Z level=INFO source=node_exporter.go:14>
Aug 14 12:57:48 slv12 node_exporter[28632]: time=2025-08-14T12:57:48.517Z level=INFO source=node_expo
```

curl http://10.129.0.29:9100/metrics
```
# HELP node_uname_info Labeled system information as provided by the uname system call.
# TYPE node_uname_info gauge
node_uname_info{domainname="(none)",machine="x86_64",nodename="slv12",release="6.8.0-71-generic",sysname="Linux",version="#71-Ubuntu SMP PREEMPT_DYNAMIC Tue Jul 22 16:52:38 UTC 2025"} 1
# HELP node_vmstat_oom_kill /proc/vmstat information field oom_kill.
# TYPE node_vmstat_oom_kill untyped
node_vmstat_oom_kill 0
# HELP node_vmstat_pgfault /proc/vmstat information field pgfault.
# TYPE node_vmstat_pgfault untyped
node_vmstat_pgfault 1.2760352e+07
# HELP node_vmstat_pgmajfault /proc/vmstat information field pgmajfault.
# TYPE node_vmstat_pgmajfault untyped
node_vmstat_pgmajfault 1339
# HELP node_vmstat_pgpgin /proc/vmstat information field pgpgin.
# TYPE node_vmstat_pgpgin untyped
node_vmstat_pgpgin 640291
# HELP node_vmstat_pgpgout /proc/vmstat information field pgpgout.
# TYPE node_vmstat_pgpgout untyped
node_vmstat_pgpgout 1.346479e+06
# HELP node_vmstat_pswpin /proc/vmstat information field pswpin.
```