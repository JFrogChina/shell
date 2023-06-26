#! /bin/sh

>results

# read gpwxxx.log
ls -v nginx* | while read log_file;do
    
    echo $log_file

    # This line extracts the fourth field from each line of the log file (assuming it's space-separated) using awk
    # then extracts a specific range of characters using cut
    # and finally sorts and removes duplicates using sort and uniq. 
    # The resulting hours are stored in the variable hours.
    hours=$(awk '{print $4}' $log_file | cut -c 2-15 | sort |uniq)

    echo "$hours" | while read hour;do
        
        # PUT
        put_count=`cat $log_file| grep $hour | grep PUT |wc -l`
        if [ $put_count -eq 0 ];then
            put_bytes=0
        else
            # This line extracts the byte values associated with PUT operations in the log file for the current hour using grep and awk. 
            # It removes double quotes from the second-to-last field using gsub
            # accumulates the values in the sum variable, and finally prints the sum.
            put_bytes=`cat $log_file| grep $hour | grep PUT |awk '{gsub(/"/, "", $(NF-2));sum += $(NF-2)} END {print sum}'`
        fi
        
        # GET
        get_count=`cat $log_file| grep $hour | grep GET |wc -l`
        if [ $get_count -eq 0 ];then
            get_bytes=0
        else
            get_bytes=`cat $log_file| grep $hour | grep GET |awk '{sum += $10} END {print sum}'`
        fi
        echo "$hour $put_count $put_bytes $get_count $get_bytes" >> results.log
    done
    
done
