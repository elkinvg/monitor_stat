#!/bin/bash
homedir="/home/eas/monitor_stat/"
source "$homedir"stations.sh
sta=""
TMPV=""
readtempvalue ()
{
	datfileex=`ssh $sta "cat /data/*.dat | cut -b10,11 | fgrep -a 80 | wc -l"`
	timestat=`ssh $sta "head -n 1 /data/*.dat | cut -b43-48;
	head -n 1 /data/*.dat | cut -b53-58;
	tail -n 1 /data/*.dat | cut -b43-48;
	tail -n 1 /data/*.dat | cut -b53-58;
	cat /data/*.dat | cut -b10,11 | fgrep -a 80 | wc -l;
	date --utc +%s;
	ls /data/ | grep '.dat'"`
	timestat2=`ssh $sta "
	head -n 1 /data/$TMPV | cut -b43-48;
	head -n 1 /data/$TMPV | cut -b53-58;
	tail -n 1 /data/$TMPV | cut -b43-48;
	tail -n 1 /data/$TMPV | cut -b53-58;
	sed '2!d' /data/$TMPV | awk '{print$1}';
	sed '2!d' /data/$TMPV | awk '{print$2}';
	rm /data/$TMPV"`
	
	starttime=`echo $timestat | awk '{print$1}'`
	startdate=`echo $timestat | awk '{print$2}'`
	endtime=`echo $timestat | awk '{print$3}'`
	enddate=`echo $timestat | awk '{print$4}'`
	nentries=`echo $timestat | awk '{print$5}'`
	comptime=`echo $timestat | awk '{print$6}'`
	namedatfile=`echo $timestat | awk '{print$7}'`
	
	starttimeprev=`echo $timestat2 | awk '{print$1}'`
	startdateprev=`echo $timestat2 | awk '{print$2}'`
	endtimeprev=`echo $timestat2 | awk '{print$3}'`
	enddateprev=`echo $timestat2 | awk '{print$4}'`
	comptimeprev=`echo $timestat2 | awk '{print$5}'`
	nentriesprev=`echo $timestat2 | awk '{print$6}'`
}

readvalue ()
{
	timestat=`ssh $sta "head -n 1 /data/*.dat | cut -b43-48;
	head -n 1 /data/*.dat | cut -b53-58;
	tail -n 1 /data/*.dat | cut -b43-48;
	tail -n 1 /data/*.dat | cut -b53-58;
	cat /data/*.dat | cut -b10,11 | fgrep -a 80 | wc -l;
	date --utc +%s;
	ls /data/ | grep '.dat'"`	
	if [ $? -ne "255" ]
	then
		starttime=`echo $timestat | awk '{print$1}'`
		startdate=`echo $timestat | awk '{print$2}'`
		endtime=`echo $timestat | awk '{print$3}'`
		enddate=`echo $timestat | awk '{print$4}'`
		nentries=`echo $timestat | awk '{print$5}'`
		comptime=`echo $timestat | awk '{print$6}'`
		namedatfile=`echo $timestat | awk '{print$7}'`
	else
		starttime="0"
		startdate="0"
		endtime=`date --utc +%H%M%S`
		enddate=`date --utc +%d%m%y`
		nentries="0"
		nevents="0"
		comptime=`date --utc +%s`
		nworksek="0"
		namedatfile="no_connection"		
	fi
}

TMPV="tempvalue"
for sta in $LNP11_s $LNP10_s $LNP9_s $LNP8_s $LNP7_s $LNP6_s $LNP5_s $LNP4_s $LNP3_s $LNP2_s $LNP1_s
do

	case $sta in
		$LNP1_s)
			namefile="LNP1_"`echo $sta | sed 's/\./_/g'`
			;;
		$LNP2_s)
			namefile="LNP2_"`echo $sta | sed 's/\./_/g'`
			;;
		$LNP3_s)
			namefile="LNP3_"`echo $sta | sed 's/\./_/g'`
			;;
		$LNP4_s)
			namefile="LNP4_"`echo $sta | sed 's/\./_/g'`
			;;
		$LNP5_s)
			namefile="LNP5_"`echo $sta | sed 's/\./_/g'`
			;;
		$LNP6_s)
			namefile="LNP6_"`echo $sta | sed 's/\./_/g'`
			;;
		$LNP7_s)
			namefile="LNP7_"`echo $sta | sed 's/\./_/g'`
			;;
		$LNP8_s)
			namefile="LNP8_"`echo $sta | sed 's/\./_/g'`
			;;
		$LNP9_s)
			namefile="LNP9_"`echo $sta | sed 's/\./_/g'`
			;;
		$LNP10_s)
			namefile="LNP10_"`echo $sta | sed 's/\./_/g'`
			;;
		$LNP11_s)
			namefile="LNP11_"`echo $sta | sed 's/\./_/g'`
			;;
	esac

	namefile=$homedir$namefile
	
if ssh $sta "[ -e /data/$TMPV ]"
then	
	
	#namefile=`echo $sta | sed 's/\./_/g'`
	
	readtempvalue
		
	if [ $datfileex -eq "0" ]
	then
		#nentries="0"
		comptime=`date --utc +%s`
		endtime=`date --utc +%H%M%S`
		enddate=`date --utc +%d%m%y`
		#nevents=$nentries
		#nworksek="0"
		#namedatfile=`ssh $sta "ls /data/ | grep '.dat'"`
		#namedatfile="no_data_or_no_file"
		namedatfile=`tail -n 1 $namefile | awk '{print$1}'`
		nentries=$nentriesprev
		neventsold=`tail -n 1 $namefile | awk '{print$2}'`
		comptimeold=`tail -n 1 $namefile | awk '{print$5}'`
		nevents=`expr $nentriesprev - $neventsold`
		nworksek=`expr $comptime - $comptimeold`
		
		if [ `cat $namefile | wc -l` -lt "37" ]
		then			
			echo "$namedatfile $nentries $enddate $endtime $comptime $nevents $nworksek" >> $namefile
		else
			#readtempvalue
			echo "$namedatfile $nentries $enddate $endtime $comptime $nevents $nworksek" >> $namefile
			sed '1d' $namefile > "$homedir"tmp
			cp -f "$homedir"tmp $namefile
			rm "$homedir"tmp
		fi		
		continue
	fi
	
	if [ ! -e $namefile ]
	then
		#readtempvalue
		nevents=$nentries
		nworksek="0"
		echo "$namedatfile $nentries $enddate $endtime $comptime $nevents $nworksek" > $namefile
	else
		
		if [ `cat $namefile | wc -l` -eq "0" ]
		then
			nevents=$nentries
			nworksek="0"
			echo "$namedatfile $nentries $enddate $endtime $comptime $nevents $nworksek" > $namefile
			continue
		fi
		
		#readtempvalue
		neventsold=`tail -n 1 $namefile | awk '{print$2}'`
		nevents=`expr $nentries + $nentriesprev - $neventsold`
		comptimeold=`tail -n 1 $namefile | awk '{print$5}'`
		if [ $enddateprev -eq $enddate ]
		then
			hoursold=`echo $endtimeprev | cut -b1-2`
			hoursnew=`echo $starttime | cut -b1-2`
			minold=`echo $endtimeprev | cut -b3-4`
			minnew=`echo $starttime | cut -b3-4`
			sekold=`echo $endtimeprev | cut -b5-6`
			seknew=`echo $starttime | cut -b5-6`
			deadtime=`expr "3600" '*' '(' $hoursnew - $hoursold ')' + "60" '*' '(' $minnew - $minold ')' + '(' $seknew - $sekold ')' `
		else
			dayold=`echo $enddateprev | cut -b1-2`
			daynew=`echo $enddate | cut -b1-2`
			if [ `expr $daynew - $dayold` -ne "1" ]
			then
				deadtime="0"
			else
				hoursold=`echo $endtimeprev | cut -b1-2`
				hoursnew=`echo $starttime | cut -b1-2`
				minold=`echo $endtimeprev | cut -b3-4`
				minnew=`echo $starttime | cut -b3-4`
				sekold=`echo $endtimeprev | cut -b5-6`
				seknew=`echo $starttime | cut -b5-6`
				deadtime=`expr "86400" '*' '(' $daynew - $dayold ')' + "3600" '*' '(' $hoursnew - $hoursold ')' + "60" '*' '(' $minnew - $minold ')' + '(' $seknew - $sekold ')' `
			fi
		fi
			
		nworksek=`expr $comptime - $comptimeold - $deadtime`
	
		if [ `cat $namefile | wc -l` -lt "37" ]
		then			
			echo "$namedatfile $nentries $enddate $endtime $comptime $nevents $nworksek" >> $namefile
		else
			#readtempvalue
			echo "$namedatfile $nentries $enddate $endtime $comptime $nevents $nworksek" >> $namefile
			sed '1d' $namefile > "$homedir"tmp
			cp -f "$homedir"tmp $namefile
			rm "$homedir"tmp
		fi
	fi
else

	#namefile=`echo $sta | sed 's/\./_/g'`
	readvalue
	
        if [ "$namedatfile" = "no_connection" ]
	then
            if [ `cat $namefile | wc -l` -lt "37" ]
            then
				echo "$namedatfile $nentries $enddate $endtime $comptime $nevents $nworksek" >> $namefile
				continue
            else
                echo "$namedatfile $nentries $enddate $endtime $comptime $nevents $nworksek" >> $namefile
                sed '1d' $namefile > "$homedir"tmp
                cp -f "$homedir"tmp $namefile
                rm "$homedir"tmp
                continue
            fi
	fi
	
	if [ `ssh $sta "cat /data/*.dat | cut -b10,11 | fgrep -a 80 | wc -l"` -eq "0" ]
	then
		nentries="0"
		comptime=`date --utc +%s`
		endtime=`date --utc +%H%M%S`
		enddate=`date --utc +%d%m%y`
		nevents=$nentries
		nworksek="0"
		#namedatfile=`ssh $sta "ls /data/ | grep '.dat'"`
		namedatfile="no_data_or_no_file"
		if [ `cat $namefile | wc -l` -lt "37" ]
		then			
			echo "$namedatfile $nentries $enddate $endtime $comptime $nevents $nworksek" >> $namefile
		else
			#readtempvalue
			echo "$namedatfile $nentries $enddate $endtime $comptime $nevents $nworksek" >> $namefile
			sed '1d' $namefile > "$homedir"tmp
			cp -f "$homedir"tmp $namefile
			rm "$homedir"tmp
		fi
		continue
	fi
	
	if [ ! -e $namefile ]
	then
		#readvalue
		nevents=$nentries
		nworksek="0"
		echo "$namedatfile $nentries $enddate $endtime $comptime $nevents $nworksek" > $namefile
	else
		
		if [ `cat $namefile | wc -l` -eq "0" ]
		then
			nevents=$nentries
			nworksek="0"
			echo "$namedatfile $nentries $enddate $endtime $comptime $nevents $nworksek" > $namefile
			continue
		fi
	
		if [ `cat $namefile | wc -l` -lt "37" ]
		then
			#readvalue
			neventsold=`tail -n 1 $namefile | awk '{print$2}'`
			nevents=`expr $nentries - $neventsold`
			comptimeold=`tail -n 1 $namefile | awk '{print$5}'`
			nworksek=`expr $comptime - $comptimeold`
			echo "$namedatfile $nentries $enddate $endtime $comptime $nevents $nworksek" >> $namefile
		else
			#readvalue
			neventsold=`tail -n 1 $namefile | awk '{print$2}'`
			nevents=`expr $nentries - $neventsold`
			comptimeold=`tail -n 1 $namefile | awk '{print$5}'`
			nworksek=`expr $comptime - $comptimeold`
			echo "$namedatfile $nentries $enddate $endtime $comptime $nevents $nworksek" >> $namefile
			sed '1d' $namefile > "$homedir"tmp
			cp -f "$homedir"tmp $namefile
			rm "$homedir"tmp
		fi
	fi
fi
done
