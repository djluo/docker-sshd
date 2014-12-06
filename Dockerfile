# SSHD
#
# Version 4

FROM debian
MAINTAINER djluo <dj.luo@baoyugame.com>

RUN apt-get update \
    && apt-get install -y openssh-server \
    && apt-get clean \
    && rm -rf usr/share/locale \
    && rm -rf usr/share/man    \
    && rm -rf usr/share/doc    \
    && rm -rf usr/share/info   \
    && find var/lib/apt -type f -exec rm -fv {} \; \
    && rm -f /etc/motd

ADD ./cmd.sh /cmd.sh
ADD ./sshd_config /etc/ssh/

EXPOSE 22

CMD ["/cmd.sh"]
