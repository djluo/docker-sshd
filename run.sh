#!/bin/bash
# vim:set et ts=2 sw=2:

# chkconfig: 3 96 19
# description:
# processname: sshd & sftp container

# 当前工作目录相关
current_dir=`readlink -f $0`
current_dir=`dirname $current_dir`

cd ${current_dir} && export current_dir

images="sshd:4"

action="$1"    # start or stop ...
app_name="$2"  # is container name
app_port="$3"  # master port

app_name=${app_name:=ssh-server}
app_port=${app_port:=127.0.0.1:3555}

port="-p $app_port:22"

# 读取当前应用配置
[ -f  ${current_dir}/.lock_source ] && source ${current_dir}/.lock_source

# 检查输入
if ! `echo ${app_name} | egrep "^[a-z][a-z0-9_-]{0,20}$" >/dev/null` ;then
  echo "app_name bad: $app_name"
  exit 127
fi
if ! `echo ${port} | egrep "^-p[ p0-9:.-]{0,100}$" >/dev/null` ;then
  echo "app_port bad: $app_port"
  exit 128
fi

# 检查镜像是否存在
#_check_images() {
#
#}

_usage() {
  echo "Usage: $0 [start|stop|restart|rebuild|remove|debug] [name] [port]..."
  echo "     : name current is \"${app_name}\""
  echo "     : port current is \"${port}\""
  echo "     : name defalut is \"ssh-server\""
  echo "     : port defalut is \"-p 127.0.0.1:3555:22\""
  exit 127
}

_check_container() {
  local status=""
  status=$(sudo docker inspect --format='{{ .State.Running }}' $app_name 2>/dev/null)
  local retvar=$?

  if [ $retvar -eq 0 ] ;then
    [ "x$status" == "xtrue"  ] && return 0 # exists and running
    [ "x$status" == "xfalse" ] && return 1 # exists and stoped
    return 2 # is images or Unknown
  else
    return 3 # No such image or container
  fi
}
_status() {
  _check_container
  local cstatus=$?

  echo -en "Status container: ${app_name} \t"

  if [ $cstatus -eq 0 ] ;then
    echo "exists and running"
    echo "        and port: ${port}"
  elif [ $cstatus -eq 1 ];then
    echo "exists and stoped"
    echo "        and port: ${port}"
  elif [ $cstatus -eq 2 ];then
    echo "is images or Unknown"
  elif [ $cstatus -eq 3 ];then
    echo "not exists"
  else
    echo "is Unknown"
  fi
}
_run() {
  # usage:
  #   call: _run
  #   call: _run debug
  local mode="-d"
  local volume=""
  local name="$app_name"

  if [ "x$1" == "xdebug" ];then
    shift
    mode="-ti --rm"
    name="debug_$app_name"
    cmd="/bin/bash -l"
    unset port
  else
    cmd="/cmd.sh $app_name"
  fi

  [ -f ${current_dir}/conf/authorized_keys ] && \
    volume="-v ${current_dir}/conf/authorized_keys:/home/docker/.ssh/authorized_keys"

  local User_Id="$app_port"
  if `id -u baoyu >/dev/null 2>&1` ;then
    User_Id=`id -u baoyu`
  fi

  sudo docker run $mode $port \
    -e "TZ=Asia/Shanghai"     \
    -e "User_Id=$User_Id"     \
    $volume \
    -v ${current_dir}/html:/home/docker/html \
    --name ${name} ${images} $cmd
}
_start() {
  local retvar=1

  echo -en "Start  container: ${app_name} \t"

  _check_container
  local cstatus=$?

  if [ $cstatus -eq 0 ] ;then
    echo -en "is running\t"
    retvar=0
  elif [ $cstatus -eq 1 ];then
    sudo docker start $app_name >/dev/null
    _check_container
    [ $? -eq 0 ] && retvar=0
  elif [ $cstatus -eq 3 ];then
    _run >/dev/null
    _check_container
    [ $? -eq 0 ] && retvar=0
  else
    echo -en "Unknown\t"
    retvar=1
  fi

  if [ $retvar -eq 0 ] ;then
    # 写入当前应用配置
    if [ ! -f  ${current_dir}/.lock_source ];then
      echo "app_name='${app_name}'" > ${current_dir}/.lock_source
      echo "port='${port}'"    >>${current_dir}/.lock_source
    fi
    echo "OK"
  else
    echo "Failed"
  fi
}
_stop() {
  local retvar=1

  echo -en "Stop   container: ${app_name} \t"

  _check_container
  local cstatus=$?

  if [ $cstatus -eq 0 ] ;then
    sudo docker stop -t 2 ${app_name} >/dev/null
    _check_container
    [ $? -eq 1 ] && retvar=0
  elif [ $cstatus -eq 1 ];then
    echo -en "is stoped\t"
    retvar=0
  else
    echo -en "No such container\t"
    retvar=1
  fi

  if [ $retvar -eq 0 ];then
    echo "OK"
  else
    echo "Failed"
    exit 127
  fi
}
_remove(){
  local retvar=1

  echo -en "Remove container: ${app_name} \t"

  _check_container
  local cstatus=$?

  if [ $cstatus -eq 1 ];then
    sudo docker rm ${app_name} >/dev/null
    retvar=$?
  else
    retvar=1
  fi

  if [ $retvar -eq 0 ];then
    # rm -f ${current_dir}/.lock_source
    echo "OK"
  else
    echo "Failed"
  fi

}
###############

case "$action" in
  start)
    _start
    ;;
  stop)
    _stop
    ;;
  debug)
    _run debug
    ;;
  restart)
    _stop
    _start
    ;;
  rebuild)
    _stop
    _remove
    _start
    ;;
  remove)
    _stop
    _remove
    ;;
  status)
    _status
    ;;
  *)
    _usage
    ;;
esac
