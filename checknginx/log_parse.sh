#!/bin/bash

cluster_name="test_custer"
file_name="nginx.log"
minus_hour=1
minus_day=0

if [ -n "$1" ]; then
  cluster_name="$1"
fi

if [ -n "$2" ]; then
  file_name="$2"
fi

if [ -n "$3" ]; then
  minus_hour="$3"
fi

if [ -n "$4" ]; then
  minus_day="$4"
fi

echo
echo "1 - check log of last hour"
echo "./log_parse.sh"
echo
echo "2 - check cluster_name file_name minus_hour minus_day"
echo "./log_parse.sh test_custer /Users/kyle/Downloads/op/nginx.log 1 0"
echo
echo "now checking by cluster_name=$cluster_name, file_name=$file_name, minus_hour=$minus_hour, minus_day=$minus_day"
echo

# mac date vs linux date - https://www.jibing57.com/2017/08/03/date-command-on-Linux-and-Mac/
os=$(uname -s)
if [[ "$os" == "Linux" ]]; then
    # 18/Jun/2023:23
    log_time=`eval "date -d -$minus_hour""hour -d -$minus_day""days +\"%d/%b/%Y:%H\""`
    # 2023-06-18 23:00:00
    log_time1=`eval "date -d -$minus_hour""hour -d -$minus_day""days +\"%Y-%m-%d %H\":00:00"`
    echo "checking log_time1=$log_time1"
elif [[ "$os" == "Darwin" ]]; then
    log_time=`eval "date -v-$minus_hour""H -v-$minus_day""d \"+%d/%b/%Y:%H\""`
    log_time1=`eval "date -v-$minus_hour""H -v-$minus_day""d \"+%Y-%m-%d %H\":00:00"`
    echo "checking log_time1=$log_time1"
else
    echo "unknown OS"
    exit 1
fi

put=`grep '\"PUT' $file_name|grep $log_time|awk -F '\"' 'BEGIN { count=0; sum=0; } { count++; sum+=$10; } END { print count; print " ", sum; }'`
put_count=`echo $put|awk '{print $1}'`
put_size=`echo $put|awk '{print $2}'`
get=`grep '\"GET' $file_name|grep $log_time|awk 'BEGIN { count=0; sum=0; } { count++; sum+=$10; } END { print count; print " ", sum; }'` 
get_count=`echo $get|awk '{print $1}'`
get_size=`echo $get|awk '{print $2}'`

# get IP of current host
log_ip="x.x.x.x"

echo
echo \"cluster_name\",\"log_time1\",\"log_ip\",\"put_count\",\"put_size\",\"get_count\",\"get_size\"
echo \"$cluster_name\",\"$log_time1\",\"$log_ip\",\"$put_count\",\"$put_size\",\"$get_count\",\"$get_size\"
echo
