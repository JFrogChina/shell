#!/bin/bash
clusterName=gpw20
filesName=`find /root/log_sum/ -name "${clusterName}.myoas.com-access.log"`
currentTime=`date -d -1hour -d -11days +"%d/%b/%Y:%H"`
dateFormat=`date -d -1hour -d -11days +"%Y-%m-%d %H"`:00:00
echo $dateFormat

ip_get=`grep '\"GET' $filesName|grep $currentTime|awk '{ count[$1]++; sum[$1]+=$10; } END { for (key in count) { print key, count[key], sum[key] ,"\n" } }'`
ip_put=`grep '\"PUT' $filesName|grep $currentTime|sed 's/\"//g'|awk '{ count[$1]++; sum[$1]+=$14; } END { for (key in count) { print key, count[key], sum[key] ,"\n" } }'`

get_size=0
get_count=0
put_size=0
put_count=0

IFS=$'\n' read -r -d '' -a ip_get_lines <<< "$ip_get"
IFS=$'\n' read -r -d '' -a ip_put_lines <<< "$ip_put"
for ip_get_each in "${ip_get_lines[@]}" 
do
	ip_get_count=`echo $ip_get_each|awk '{print $2}'`
	ip_get_size=`echo $ip_get_each|awk '{print $3}'`
	get_size=$(($ip_get_size+$get_size))
	get_count=$(($ip_get_count+$get_count))
done

for ip_put_each in "${ip_put_lines[@]}"
do  
        ip_put_count=`echo $ip_put_each|awk '{print $2}'`
        ip_put_size=`echo $ip_put_each|awk '{print $3}'`
	put_size=$(($ip_put_size+$put_size))
	put_count=$(($ip_put_count+$put_count))
done
echo \"$dateFormat\",\"$put_count\",\"$put_size\",\"$get_count\",\"$get_size\"

put=`grep '\"PUT' $filesName|grep $currentTime|awk -F '\"' 'BEGIN { count=0; sum=0; } { count++; sum+=$10; } END { print count; print " ", sum; }'`
put_count=`echo $put|awk '{print $1}'`
put_size=`echo $put|awk '{print $2}'`
get=`grep '\"GET' $filesName|grep $currentTime|awk 'BEGIN { count=0; sum=0; } { count++; sum+=$10; } END { print count; print " ", sum; }'` 
get_count=`echo $get|awk '{print $1}'`
get_size=`echo $get|awk '{print $2}'`

echo \"$dateFormat\",\"$put_count\",\"$put_size\",\"$get_count\",\"$get_size\"
