

system_hour=$(date -v -8H +"%d/%b/%Y:%H")
system_hour="17/Jun/2023:01"

current_line=$(grep -m 1 -n $system_hour nginx.log | cut -d ':' -f 1)
echo "Current line: $current_line"

first_line=$(grep -m 1 $system_hour nginx.log)
echo "first_line=$first_line"