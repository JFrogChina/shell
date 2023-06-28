#!/bin/bash
clusterName=gpw20
filesName=`find /root/log_sum/ -name "${clusterName}.myoas.com-access.log"`
currentTime=`date -d -1hour -d -11days +"%d/%b/%Y:%H"`
dateFormat=`date -d -1hour -d -11days +"%Y-%m-%d %H"`:00:00
echo $dateFormat

put=`grep '\"PUT' $filesName|grep $currentTime|awk -F '\"' 'BEGIN { count=0; sum=0; } { count++; sum+=$10; } END { print count; print " ", sum; }'`
put_count=`echo $put|awk '{print $1}'`
put_size=`echo $put|awk '{print $2}'`
get=`grep '\"GET' $filesName|grep $currentTime|awk 'BEGIN { count=0; sum=0; } { count++; sum+=$10; } END { print count; print " ", sum; }'` 
get_count=`echo $get|awk '{print $1}'`
get_size=`echo $get|awk '{print $2}'`

echo \"$dateFormat\",\"$put_count\",\"$put_size\",\"$get_count\",\"$get_size\"
