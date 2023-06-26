#!/bin/bash

# 记录开始时间
start_time=$(date +%s)

LOG_FILE="nginx.log"  # 替换为实际的日志文件路径

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
echo

# 从系统时间的前一小时开始读取 (日志里时间不包含8小时时差，所以减去8小时时差，再减去1小时)
system_last_hour=$(date -v -9H +"%d/%b/%Y:%H")

# *****************
# test hour
# *****************
system_last_hour="17/Jun/2023:23"
system_last_hour="18/Jun/2023:00"

echo "system_last_hour=$system_last_hour"

first_line_number=$(grep -m 1 -n "$system_last_hour" "$LOG_FILE" | cut -d ':' -f 1)
echo "reading from first_line_number=$first_line_number"


# 读取日志文件的第一行
first_line=$(grep -m 1 "$system_last_hour" "$LOG_FILE" )
echo "first_line=$first_line"

# 提取第一行的日期和小时
timestamp=$(echo "$first_line" | awk -F'[' '{print $2}' | awk -F']' '{print $1}')

# 转换格式
formatted_date=$(date -j -f "%d/%b/%Y:%H:%M:%S %z" "$timestamp" "+%Y-%m-%d")
formatted_time=$(date -j -f "%d/%b/%Y:%H:%M:%S %z" "$timestamp" "+%H:%M:%S")
formatted_timestamp="$formatted_date""T""$formatted_time"".000Z"

current_date=${formatted_timestamp:0:10}
current_hour=${formatted_timestamp:11:2}

# 初始化变量
request_length_sum=0
response_length_sum=0

echo
echo "date, date_hour, upload(mb), download(mb)"
echo "date, date_hour, upload(mb), download(mb)" > checklog-result.csv
echo

# 最大行数
MAX_LINES=$(wc -l < "$LOG_FILE")
# 根据末尾的换行符计算会少一行
((MAX_LINES++))

echo "MAX_LINES=$MAX_LINES"

lines_to_read=$((MAX_LINES - first_line_number))
echo "lines_to_read=$lines_to_read"

# 从文件末尾开始读取
tail -n $lines_to_read "$LOG_FILE" | {
  
  # 当前行
  current_line_number=1
  while ((current_line_number <= lines_to_read)) ; do
  
    IFS= read -r line

    # echo $line
    # echo "current_line_number=$current_line_number, MAX_LINES=$MAX_LINES"
    
    ip_address=$(echo "$line" | awk '{print $1}')
    user=$(echo "$line" | awk '{print $3}')
    timestamp=$(echo "$line" | awk -F'[' '{print $2}' | awk -F']' '{print $1}')
    method=$(echo "$line" | awk -F'"' '{print $2}' | awk '{print $1}')
    uri=$(echo "$line" | awk -F'"' '{print $2}' | awk '{print $2}')
    http_version=$(echo "$line" | awk -F'"' '{print $3}' | awk '{print $1}')
    status_code=$(echo "$line" | awk '{print $9}')
    bytes=$(echo "$line" | awk '{print $10}')
    user_agent=$(echo "$line" | awk -F'"' '{print $6}')
    duration=$(echo "$line" | awk '{print $10}')
    server_ip=$(echo "$line" | awk '{print $NF}')

    # 提取日期和小时

    # 转换格式
    formatted_date=$(date -j -f "%d/%b/%Y:%H:%M:%S %z" "$timestamp" "+%Y-%m-%d")
    formatted_time=$(date -j -f "%d/%b/%Y:%H:%M:%S %z" "$timestamp" "+%H:%M:%S")
    formatted_timestamp="$formatted_date""T""$formatted_time"".000Z"

    log_date=${formatted_timestamp:0:10}
    log_hour=${formatted_timestamp:11:2}
    
    # echo "IP Address=$ip_address"
    # echo "User=$user"
    
    # echo "Timestamp-d=$log_date"
    # echo "Timestamp-d=$log_hour"
    
    # echo "Method=$method"
    # echo "URI=$uri"
    # echo "HTTP Version=$http_version"
    # echo "Status Code=$status_code"
    # echo "Bytes=$bytes"
    # echo "User Agent=$user_agent"
    # echo "Duration=$duration"
    # echo "Server IP=$server_ip"

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
      request_length_sum=$((request_length_sum + bytes))
    elif [[ "$method" == "GET" ]]; then
      response_length_sum=$((response_length_sum + bytes))
      # echo "GET Bytes=$bytes, response_length_sum=$response_length_sum"
    fi

    ((current_line_number++))

  done

  # 打印最后一个时间点
  request_length_mb=$(awk "BEGIN{printf \"%.2f\", $request_length_sum/(1024*1024)}")
  response_length_mb=$(awk "BEGIN{printf \"%.2f\", $response_length_sum/(1024*1024)}")

  current_hour_plus_hours=$((current_hour + param2))
  current_hour=${current_hour#0}

  echo "$current_date, $current_date"_"$current_hour_plus_hours, $request_length_mb, $response_length_mb"
  echo "$current_date, $current_date"_"$current_hour_plus_hours, $request_length_mb, $response_length_mb" >> checklog-result.csv
  echo

  # 记录结束时间
  end_time=$(date +%s)

  # 计算执行时间
  execution_time=$((end_time - start_time))

  # 显示执行时间
  echo "exec time=${execution_time}s"

}

