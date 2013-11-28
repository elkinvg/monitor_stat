#!/bin/bash
TMPV="tempvalue"
comptime=`date +%s`
nevents=`cat /data/*.dat | cut -b10,11 | fgrep -a 80 | wc -l`
if [ $nevents -ne "0" ]
then
	head -n 1 /data/*.dat > /data/$TMPV
	echo "$comptime $nevents" >> /data/$TMPV
	tail -n 1 /data/*.dat >> /data/$TMPV
fi
