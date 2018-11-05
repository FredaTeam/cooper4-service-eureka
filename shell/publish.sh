#!/bin/sh

set -e

USER_NAME=$1

if [ -z ${USER_NAME} ]; then
      echo 'please input username'
      exit 2
fi

SERVER_IP=$2

if [ -z ${SERVER_IP} ]; then
      echo 'please input server ip'
      exit 2
fi

function build(){
    cd ../ && gradle clean build
}

function upload(){
    CURRENT_PATH=`pwd`
    scp ${CURRENT_PATH}/build/libs/cooper4-service-eureka.jar ${USER_NAME}@${SERVER_IP}:/home/work/eureka.jar
}

function start(){
    ssh -T ${USER_NAME}@${SERVER_IP} sh /home/shell/start.sh /home/work/eureka
}

build
upload
start