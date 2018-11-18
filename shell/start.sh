#!/bin/sh

set -e

SERVER_PATH=$1

if [ -z ${SERVER_PATH} ]; then
      echo 'please input server path'
      exit 2
fi

SERVER_NAME=${SERVER_PATH##*/}

# 生产环境JVM参数配置
CUSTOM_JVM_ONLINE=" -Xmx512m
             -Xms512m
             -Xmn192m
             -XX:+ExplicitGCInvokesConcurrent
             -XX:MetaspaceSize=64m
             -XX:MaxMetaspaceSize=64m
             -XX:+UseConcMarkSweepGC
             -XX:+UseParNewGC
             -XX:+ScavengeBeforeFullGC
             -XX:+CMSScavengeBeforeRemark
	     -Dspring.profiles.active=dev"


CUSTOM_LOG_PATH_ONLINE="/home/logs"

DEFAULT_LOG_PATH="${SERVER_PATH}/logs"

# 指定默认日志路径
if [ -z ${LOG_PATH} ]; then
    LOG_PATH="${DEFAULT_LOG_PATH}"
fi
echo ${LOG_PATH}

# 默认参数
DEFAULT_JVM=" -Xloggc:$LOG_PATH/$SERVER_NAME.gc.log.`date +%Y%m%d%H%M`
              -XX:ErrorFile=$LOG_PATH/$SERVER_NAME.vmerr.log.`date +%Y%m%d%H%M`
              -XX:HeapDumpPath=$LOG_PATH/$SERVER_NAME.heaperr.log.`date +%Y%m%d%H%M`
              -XX:+HeapDumpOnOutOfMemoryError
              -XX:+PrintGCDetails
	      -XX:+UseGCLogFileRotation
              -XX:NumberOfGCLogFiles=10
              -XX:GCLogFileSize=100M
              -XX:+PrintGCDateStamps -verbose:gc"

function init() {
    echo ${SERVER_NAME}
    PID_NUM=$(ps aux |grep "${SERVER_NAME}\.jar"|grep -v "grep"|awk '{print $2}')
    echo ${PID_NUM}
    if [ ${PID_NUM} ] ; then
        echo kill ${SERVER_NAME}.jar
        kill  ${PID_NUM}

        echo sleep 10
        sleep 10

        PID_NUM=$(ps aux |grep "${SERVER_NAME}\.jar"|grep -v "grep"|awk '{print $2}')
        if [ ${PID_NUM} ] ; then
            echo kill -9 ${SERVER_NAME}.jar
            kill -9 ${PID_NUM}
        fi
    else
            echo ${SERVER_NAME}.jar not running
    fi
}

function run() {
    echo starting...

    if [ ! -d ${LOG_PATH} ];then
      mkdir ${LOG_PATH}
    else
      echo ${LOG_PATH} exist
    fi

    # 环境设置 ${DEFAULT_JVM}
    CUSTOM_JVM="${CUSTOM_JVM_ONLINE} ${DEFAULT_JVM}"
    # ln -s ${CUSTOM_LOG_PATH_ONLINE} ${SERVER_PATH}/logs


    exec /home/java/bin/java ${CUSTOM_JVM} -jar ${SERVER_PATH}.jar  > ${SERVER_PATH}/startup.log 2>&1 &

    echo run finished
}

init
run