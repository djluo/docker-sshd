# 介绍
基于CentOS 7的sshd容器
建议只用来管理其他容器,通过挂载其他容器的VOLUME来实现

## 创建镜像：
1. 获取：
<pre>
cd ~
git clone https://github.com/djluo/docker-sshd.git
</pre>
2. 构建镜像：
<pre>
cd ~/docker-sshd
sudo docker build -t sshd   .
sudo docker build -t sshd:1 .
</pre>

##  使用：

1. 启动容器：
<pre>
CID=$(sudo docker run -d -p 1234:22 --privileged --name app.sshd sshd)
</pre>
2. 获取登录密码：
<pre>
sudo docker logs $CID
</pre>
3.  登录SSH：
<pre>
ssh -p1234 root@127.0.0.1
</pre>
