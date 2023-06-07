#!/bin/sh

# put multiple result for each rotated log file into 1 folder
# format of each result = $hour $put_count $put_bytes $get_count $get_bytes
# The PROCINFO["sorted_in"] sets the sorting order to ascending based on the array indexes (hours).

# combine resultsxxx files into final_result, order by asc
awk '{
        sum[$1] += $2;
        sum2[$1] += $3;
        sum3[$1] += $4;
        sum4[$1] += $5
}
END {
        PROCINFO["sorted_in"] = "@ind_str_asc";
        for (i in sum)
                print i, sum[i], sum2[i], sum3[i], sum4[i]
}' results* > final_result
 
# delete data that is less than 24 hours
first_date=$(awk 'NR == 1 {print $1}' final_result)
last_date=$(awk 'END {print $1}' final_result)
sed -i "\#${first_date}#d" final_result
sed -i "\#${last_date}#d" final_result

# sum for everyday in final_result
awk '{
        split($1, date, /[:]/);
        sum1[date[1]] += $2;
        sum2[date[1]] += $3;
        sum3[date[1]] += $4;
        sum4[date[1]] += $5;
}
END {
        for (d in sum1) {
            printf("%s %d %d %d %d\n", d, sum1[d], sum2[d], sum3[d], sum4[d]);
        }
}' final_result | sort -k1,1 -t'/' -k2n

# change date format to e.g. 040401

# cat final_result | while read line;do
#         date_str=$(echo $line | awk '{print $1}')
#         date_s=$(echo $date_str | awk -F':' '{print $1}')
#         hour_s=$(echo $date_str | awk -F':' '{print $2}')
#         date_s2=$(date -d "${data_s//\// }" '+%m%d')
#         date_s1=$(echo ${date_s2}${hour_s})
#         sed -i "s|$date_str|$date_s1|" final_result
# done

# more efficient
awk '{
        date_str = $1;
        date_s = substr(date_str, 1, 8);
        hour_s = substr(date_str, 10, 2);
        date_s2 = strftime("%m%d", mktime(substr(date_s, 1, 2) " " substr(date_s, 3, 2) " " substr(date_s, 5, 2) " 00 00 00"));
        date_s1 = date_s2 hour_s;
        gsub(date_str, date_s1);
        print;
}' final_result > final_result_temp

mv final_result_temp final_result
