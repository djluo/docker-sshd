# SSHD
#
# Version 3

FROM centos
MAINTAINER djluo <dj.luo@baoyugame.com>

RUN rpm --import /etc/pki/rpm-gpg/RPM*
RUN yum install -y openssh-server initscripts; yum clean all

RUN /usr/sbin/sshd-keygen

ADD ./start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 22

CMD ["/start.sh"]
