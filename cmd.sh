#!/bin/bash

User_Id="${User_Id:=1000}"
if ! `id -u ${User_Id} >/dev/null 2>&1` ;then
  /usr/sbin/groupadd -g ${User_Id} docker >/dev/null 2>&1
  /usr/sbin/useradd  -u ${User_Id} -g ${User_Id} -m -s /bin/bash docker >/dev/null 2>&1
  chown -R docker.docker /home/docker/

  pw=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c8`
  mkdir /var/run/sshd
  chmod 600 /etc/ssh/sshd_config
  echo "============================"
  echo " root/docker password: $pw"
  echo "============================"

  echo "docker:$pw" | chpasswd
  echo "root:$pw"   | chpasswd
fi

exec /usr/sbin/sshd -D
