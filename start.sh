#!/bin/sh

pw=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c8`
echo "============================"
echo " root password: $pw"
echo "============================"

echo "root:$pw" | chpasswd

/usr/sbin/sshd -D
