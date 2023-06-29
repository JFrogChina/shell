#!/bin/bash

filesName="nginx.log"
minusHour=1
minusDay=0

if [ -n "$1" ]; then
  filesName="$1"
fi

if [ -n "$2" ]; then
  minusHour="$2"
fi

if [ -n "$3" ]; then
  minusDay="$3"
fi

echo
echo "1 - check last hour"
echo "./log_parse.sh"
echo
echo "2 - check filesName minusHour minusDay"
echo "./log_parse.sh /Users/kyle/Downloads/op/nginx.log 1 0"
echo
echo "currently checking by filesName=$filesName, minusHour=$minusHour, minusDay=$minusDay"
echo

# mac date vs linux date - https://www.jibing57.com/2017/08/03/date-command-on-Linux-and-Mac/
os=$(uname -s)
if [[ "$os" == "Linux" ]]; then
    currentTime=`eval "date -d -$minusHour""hour -d -$minusDay""days +\"%d/%b/%Y:%H\""`
    dateFormat=`eval "date -d -$minusHour""hour -d -$minusDay""days +\"%Y-%m-%d %H\":00:00"`
    echo $dateFormat
elif [[ "$os" == "Darwin" ]]; then
    # 18/Jun/2023:23
    currentTime=`eval "date -v-$minusHour""H -v-$minusDay""d \"+%d/%b/%Y:%H\""`
    # 2023-06-18 23:00:00
    dateFormat=`eval "date -v-$minusHour""H -v-$minusDay""d \"+%Y-%m-%d %H\":00:00"`
    echo $dateFormat
else
    echo "unknown OS"
    exit 1
fi

put=`grep '\"PUT' $filesName|grep $currentTime|awk -F '\"' 'BEGIN { count=0; sum=0; } { count++; sum+=$10; } END { print count; print " ", sum; }'`
put_count=`echo $put|awk '{print $1}'`
put_size=`echo $put|awk '{print $2}'`
get=`grep '\"GET' $filesName|grep $currentTime|awk 'BEGIN { count=0; sum=0; } { count++; sum+=$10; } END { print count; print " ", sum; }'` 
get_count=`echo $get|awk '{print $1}'`
get_size=`echo $get|awk '{print $2}'`

echo \"$dateFormat\",\"$put_count\",\"$put_size\",\"$get_count\",\"$get_size\"
