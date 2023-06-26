#!/bin/bash

log_file="nginx.log"  # 设置日志文件路径

while IFS= read -r line; do
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


  # 转换格式
  formatted_date=$(date -j -f "%d/%b/%Y:%H:%M:%S %z" "$timestamp" "+%Y-%m-%d")
  formatted_time=$(date -j -f "%d/%b/%Y:%H:%M:%S %z" "$timestamp" "+%H:%M:%S")
  formatted_timestamp="$formatted_date""T""$formatted_time"".000Z"

  log_date=${formatted_timestamp:0:10}
  log_hour=${formatted_timestamp:11:2}



  # 在此处添加您需要的操作，例如打印解析后的字段或将其存储到变量中进行进一步处理
  echo "IP Address: $ip_address"
  echo "User: $user"
  
  echo "Timestamp-d: $log_date"
  echo "Timestamp-d: $log_hour"
  
  echo "Method: $method"
  echo "URI: $uri"
  echo "HTTP Version: $http_version"
  echo "Status Code: $status_code"
  echo "Bytes: $bytes"
  echo "User Agent: $user_agent"
  echo "Duration: $duration"
  echo "Server IP: $server_ip"

done < "$log_file"


# IP Address: 0.0.229.79
# User: build_xxx
# Timestamp: 17/Jun/2023:00:02:14 +0800
# Method: PUT
# URI: /artifactory/xxx-local/xxx/xxx/xxx.0.0/xxx/Release/user/1.1.03/1.1.03-xxx-xxx/xxx/vendor/vintf/21642/xxx_device_compatibility_matrix.json;;
# HTTP Version: 201
# Status Code: 201
# Bytes: 1268
# User Agent: jfrog-cli-go/1.41.2.3
# Duration: "jfrog-cli-go/1.41.2.3"
# Server IP: "-"
# Client IP: "4192"
