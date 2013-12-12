#!/bin/bash

export SITE=`hostname`
cd /data

while [ true ] 
do 
if [ -e /data/STOP ]; then break; fi

export DATE=`date +%Y%m%d%H%M`

/opt/qnetdaq/qnetdaq2 -c /opt/qnetdaq/qnet.conf -o ${SITE}_${DATE} >& /dev/null

source /opt/qnetdaq/ifstop.sh
gzip ./${SITE}_${DATE}.*
scp ./*.gz eas@eas.jinr.ru:data/run_2009/
rm ./${SITE}_${DATE}.*

done
