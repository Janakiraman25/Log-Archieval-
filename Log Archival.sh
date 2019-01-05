#!/bin/sh
cd /opt/product/GTS/
Filename="$0"
h=2
path_file=`echo "$Filename"|sed 's/MANAGER/PATH/'|sed 's/.sh//'| sed 's/$/.xml/'`
path_folder=`echo "$Filename"|sed 's/_MANAGER//'|sed 's/.sh//'`
mkdir -p $path_folder

file_check=$path_file
lt=`perl -e '@T=localtime(time-(3600));printf("%02d_%02d_20%02d",$T[3],$T[4]+1,($T[5]+1900)%100)' |awk -F"_" '{print $3"_"$2"_"$1}'`
rl=`echo "PROCESSING_LOGS_$lt.log"`
erl=`echo "ERROR_LOGS_$lt.log"`
wrl=`echo "WARNING_LOGS_$lt.log"`
nrl=`echo "NOTICE_LOGS_$lt.log"`
echo "" >> $path_folder/$rl
if [ ! -f "$file_check" ]; then echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Error] Config File not found. Hence Exiting from Script" >> $path_folder/$erl; echo "" >> $path_folder/$erl; exit 1; fi
while LM=`ps -ef | grep -v 'grep' | grep "$Filename" |grep -v "vi $Filename"| awk {'print $2'}|wc -l` ;
do
if [ "$LM" -eq 1 ]
then
echo "**********Log Movement Process Started**********" >> $path_folder/$rl
echo "" >> $path_folder/$rl
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Info] Managing Application Logs" >> $path_folder/$rl
echo "" >> $path_folder/$rl
tcount=`grep T_COUNT $path_file | sed "s/[^0-9]//g"`
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Debug] Template Count Declared: $tcount" >> $path_folder/$rl
j=1
until [ $j -gt $tcount ]
do
count=`awk '/T'$j'/,/\/T'$j'/' $path_file|grep "PATH_COUNT" | sed "s/[^0-9]//g"`
echo "" >> $path_folder/$rl
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Debug] Performing Movement on Template: $j" >> $path_folder/$rl
echo "" >> $path_folder/$rl
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Debug] Path Count Declared: $count" >> $path_folder/$rl
echo "" >> $path_folder/$rl
i=1
until [ $i -gt $count ]
do
cd /opt/product/GTS/
echo "" >> $path_folder/$rl
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Debug] Proceeding to Path: $i" >> $path_folder/$rl
echo "" >> $path_folder/$rl
today=`perl -e '@T=localtime(time-(3600));printf("%02d_%02d_20%02d",$T[3],$T[4]+1,($T[5]+1900)%100)' |awk -F"_" '{print $3"_"$2"_"$1}'`
m=`awk '/T'$j'/,/\/T'$j'/' $path_file|grep MAX_DAYS_LOGS | sed "s/[^0-9]//g"`
nfsmount=`perl -e '@T=localtime(time-('$m'*24*3600));printf("%02d_%02d_20%02d",$T[3],$T[4]+1,($T[5]+1900)%100)' |awk -F"_" '{print $3"_"$2"_"$1}'`
CURRPATH=`awk '/T'$j'/,/\/T'$j'/' $path_file|grep -w "PATH_$i"  | awk -F"|" '{print $1}' |awk -F">" '{print $2}'`
hhstr1=`perl -e '@T=localtime(time-(3600));printf("%02d_%02d_20%02d",$T[3],$T[4]+1,($T[5]+1900)%100)' |awk -F"_" '{print $3"_"$2"_"$1}'`
hhstr2=`perl -e '@T=localtime(time-(1*24*3600));printf("%02d_%02d_20%02d",$T[3],$T[4]+1,($T[5]+1900)%100)' |awk -F"_" '{print $3"_"$2"_"$1}'`
EXT1=$hhstr1
EXT2=$hhstr2
BACKUPPATH=`awk '/T'$j'/,/\/T'$j'/' $path_file|grep -w "PATH_$i" | awk -F"|" '{print $2}'|awk -F"<" '{print $1}'`
mkdir -p $BACKUPPATH
mkdir -p $BACKUPPATH/"$today"
BB=$BACKUPPATH/"$today"/
RB=$BACKUPPATH/"$nfsmount"
L1=`cd $CURRPATH ; ls -ltr *$EXT1* *$EXT2* |awk '{print $9}'`
if [ "$L1" ]
then
L2=`echo "$L1"|xargs -n 1|sed '$d'`
if [ "$L2" ]
then
cd $CURRPATH
L3=`echo $L2|xargs -n 1|awk '/'$hhstr1'/{print}'`
L4=`echo $L2|xargs -n 1|awk '/'$hhstr2'/{print}'`
if [ "$L3" ]
then
mv $L3 $BB
cd $BB
gzip -f $L3
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Debug] Moved and Zipped Current Day files from $CURRPATH Path to $BB Path" >> $path_folder/$rl
else
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Notice] No Current Day files to Process in $CURRPATH path" >> $path_folder/$nrl
echo "" >> $path_folder/$rl
fi
if [ "$L4" ]
then
cd $CURRPATH
mv $L4 $BB
cd $BB
gzip -f $L4
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Debug] Moved and Zipped Previous Day files from $CURRPATH Path to $BB Path" >> $path_folder/$rl
fi
else
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Debug] No files to process in $CURRPATH path" >> $path_folder/$rl
echo "" >> $path_folder/$rl
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Notice] No files to process in $CURRPATH path" >> $path_folder/$nrl
echo "" >> $path_folder/$nrl
fi
else
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Debug] No files present in $CURRPATH path" >> $path_folder/$rl
echo "" >> $path_folder/$rl
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Notice] No files present in $CURRPATH path" >> $path_folder/$nrl
echo "" >> $path_folder/$nrl
fi
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Debug] Processing completed, receding from Path: $i" >> $path_folder/$rl
echo "" >> $path_folder/$rl

if [ -d "$RB" ]; then rm -rf $RB; echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Debug] Removing Logs in $BACKUPPATH Older than $m Days" >> $path_folder/$rl; echo "" >> $path_folder/$rl; fi

i=`expr $i + 1`
done
j=`expr $j + 1`
done
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Info] Completed Managing Application Logs" >> $path_folder/$rl
echo "" >> $path_folder/$rl
echo "" >> $path_folder/$rl

echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Info] Managing Application Stats" >> $path_folder/$rl
echo "" >> $path_folder/$rl
d=`grep MAX_DAYS_STATS $path_file | sed "s/[^0-9]//g"`
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Debug] Stats to keep in Current Path: $d days" >> $path_folder/$rl
echo "" >> $path_folder/$rl
stats=`awk '/APP_STATS/,/\/APP_STATS/' $path_file | egrep -v 'APP_STATS|MAX_DAYS_STATS|PATH'| xargs -n 1 echo "find" | sed 's/$/ -mtime +'$d'|xargs rm -f;/'`
echo $stats|sh
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Info] Completed Managing Application Stats" >> $path_folder/$rl
echo "" >> $path_folder/$rl
echo "**********Log Movement Process Completed**********" >> $path_folder/$rl
find $path_folder -mtime +7|xargs rm -f
echo "" >> $path_folder/$rl
exit
else
echo "" >> $path_folder/$wrl
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Warning] Script is already running, hence moving to Sleep Mode for 10 minutes with retry: $h attempts" >> $path_folder/$wrl
echo "" >> $path_folder/$wrl
sleep 600
if [ $h -eq 0 ]
then
echo "" >> $path_folder/$erl
echo "`date|awk '{print $2\" \"$3\" \"$4}'` [Error] Retry attempts over for running the job. Hence, exiting from the Script"  >> $path_folder/$erl
echo "" >> $path_folder/$erl
exit
fi
h=`expr $h - 1`
fi
done
