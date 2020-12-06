# HomeServer

## Initial setup

### 1. install OS

Install CentOS 7 (Minimal)

### 2. change locale

Add line to `~/.bashrc`

    export LANG=en_US.UTF-8

### 3. setup keyboard

`$ localectl set-keymap jp106`

### 4. generate ssh key

Generate ssh key at another pc.

`$ ssh-keygen -t rsa -b 4096`

### 5. add public key

Add public key to HomeServer host.

`$ ssh-copy-id -i ~/.ssh/{PUBLIC_KEY} root@{IP_ADDRESS}`

### 6. configure sshd

Edit `/etc/ssh/sshd_config`

- `Port {PORT}`
- `PermitRootLogin: yes`
- `PubkeyAuthentication yes`
- `PasswordAuthentication no`

and restart sshd.

`$ systemctl restart sshd.service`

### 7. configure firewalld

- `$ firewall-cmd --zone=public --add-port={PORT}/tcp --permanent`
- `$ firewall-cmd --remove-port=22/tcp --permanent`
- `$ firewall-cmd --reload`
- `$ firewall-cmd --list-all`

## Setup host

### 1. Make secret.yml

Make `secret.yml`

`$ cp secret.yml.template secret.yml`

Add values to `secret.yml`.

### 2. Deploy

`$ ./deploy.sh`
