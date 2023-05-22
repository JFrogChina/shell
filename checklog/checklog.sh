#!/bin/bash

LOG_FILE="artifactory-request.log"  # 替换为实际的日志文件路径

# 默认按小时统计
param1="h"

# 时差小时数
param2=0

# 按日期统计输入 ./checklog.sh d
if [[ "$1" == "h" || "$1" == "d" ]]; then
  param1="$1"
fi

if [ -n "$2" ]; then
  param2="$2"
fi


echo
echo "1 - check log by hour(h)"
echo "./checklog.sh"
echo
echo "2 - check log by date(d)"
echo "./checklog.sh d"
echo
echo "3 - add time difference for reading"
echo "./checklog.sh h 8"
echo
echo "currently checking by $param1, time difference is $param2"

# 最大行数
MAX_LINES=$(wc -l < "$LOG_FILE")

# 根据末尾的换行符计算会少一行
((MAX_LINES++))

# 当前行
current_line=1

# 读取日志文件的第一行
read -r first_line < "$LOG_FILE"

# 提取第一行的日期和小时
timestamp=$(echo "$first_line" | awk -F "|" '{print $1}')
current_date=${timestamp:0:10}
current_hour=${timestamp:11:2}

# 初始化变量
request_length_sum=0
response_length_sum=0

echo
echo "date, date_hour, upload(mb), download(mb)"
echo "date, date_hour, upload(mb), download(mb)" > checklog-result.csv

while ((current_line <= MAX_LINES)) ; do
  
  IFS="|" read -r timestamp trace_id remote_addr username method url status req_content_length res_content_length req_duration user_agent; 

  # echo "current_line=$current_line, MAX_LINES=$MAX_LINES"

  # 提取日期和小时
  log_date=${timestamp:0:10}
  log_hour=${timestamp:11:2}
  
  is_different="false"

  if [[ "$param1" == "h" ]]; then
    # 每一行结果属于x日期y小时
    is_different=$( [[ "$log_date" != "$current_date" ]] || [[ "$log_hour" != "$current_hour" ]] && echo "true" || echo "false" )
  elif [[ "$param1" == "d" ]]; then
    # 每一行结果属于x日期
    is_different=$( [[ "$log_date" != "$current_date" ]] && echo "true" || echo "false" )
  fi

  # 一旦不同则打印之前结果
  if [[ "$is_different" == "true" ]]; then
    
    # 打印之前时间窗口的统计结果
    request_length_mb=$(awk "BEGIN{printf \"%.2f\", $request_length_sum/(1024*1024)}")
    response_length_mb=$(awk "BEGIN{printf \"%.2f\", $response_length_sum/(1024*1024)}")

    # 没有处理超过 24 小时情况
    current_hour=${current_hour#0}
    current_hour_plus_hours=$((current_hour + param2))

    echo "$current_date, $current_date"_"$current_hour_plus_hours, $request_length_mb, $response_length_mb"
    echo "$current_date, $current_date"_"$current_hour_plus_hours, $request_length_mb, $response_length_mb" >> checklog-result.csv
    
    # 更新当前日期和小时，并重置统计变量
    current_date=$log_date
    current_hour=$log_hour
    request_length_sum=0
    response_length_sum=0

  fi

  # 根据请求方法判断应统计的内容长度
  if [[ "$method" == "PUT" ]]; then
    request_length_sum=$((request_length_sum + req_content_length))
  elif [[ "$method" == "HEAD" ]]; then
    response_length_sum=$((response_length_sum + res_content_length))
  fi

  ((current_line++))

done < "$LOG_FILE"

# 打印最后一个时间点
request_length_mb=$(awk "BEGIN{printf \"%.2f\", $request_length_sum/(1024*1024)}")
response_length_mb=$(awk "BEGIN{printf \"%.2f\", $response_length_sum/(1024*1024)}")

current_hour_plus_hours=$((current_hour + param2))
current_hour=${current_hour#0}

echo "$current_date, $current_date"_"$current_hour_plus_hours, $request_length_mb, $response_length_mb"
echo "$current_date, $current_date"_"$current_hour_plus_hours, $request_length_mb, $response_length_mb" >> checklog-result.csv
echo