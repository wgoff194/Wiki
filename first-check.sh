#!/bin/bash

# This is my first check script
# It provides basic information about the server. 

# -------------
# Set Variables
# -------------

# Set tmp file variable and create tmp file:
if [ $USER != "root" ] 
then
	info1=/home/$USER/$(hostname)-$(date +"%F-%T".txt) 
else 
	info1=/home/$(hostname)-$(date +"%F-%T".txt)
fi

echo -e "\nTemp file location: $info1"
touch $info1

# -------------------------
# Output server data start:
# -------------------------

# Output hostname:
echo -e "Hostname: $(hostname)\n" >> $info1

# Output core count
echo -e "Cores: $(nproc)\n" >> $info1

# Output w command
echo -e "$(w)\n" >> $info1

# Ouput Memory 
echo -e "$(free -m)\n" >> $info1

# Output Disk Usage 
echo -e "$(df -h| grep -v tmpfs)\n" >> $info1

# Is EA4?
echo -e "EA4: $(if [ -f /etc/cpanel/ea4/is_ea4 ]; then echo 'Yes'; else echo 'No'; fi)\n" >> $info1

# Ouput Apache info
echo -e "Apache info:\n$(httpd -V|head -9)\n" >> $info1

# Output PHP info
echo -e "PHP info: \n$(/usr/local/cpanel/bin/rebuild_phpconf --current)\n" >> $info1

# Output mysql info 
echo -e "MySQL info:" >> $info1
mysql -e "show engines;" | grep DEFAULT | awk '{print $2" MYSQL ENGINE = "$1}'>> $info1; mysql -e "SELECT engine, count(*) tables, concat(round(sum(table_rows)/1000000,2),'M') rows, concat(round(sum(data_length)/(1024*1024*1024),2),'G') data, concat(round(sum(index_length)/(1024*1024*1024),2),'G') idx, concat(round(sum(data_length+index_length)/(1024*1024*1024),2),'G') total_size, round(sum(index_length)/sum(data_length),2) idxfrac FROM information_schema.TABLES GROUP BY engine ORDER BY sum(data_length+index_length) DESC LIMIT 10;" | grep -v NULL | awk '{print$1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"}' >> $info1
echo -e "$(echo -e "\nMysql Mem configured settings: " && awk '/(key|i.*b)_b.*r_(pool_)?(s.*|.*es)/{sub("="," "); print $1,$2}' /etc/my.cnf && echo -e "\nMysql Mem current settings: " && mysql -e "show variables" |awk '/(key|innodb)_buffer_(pool_)?(size|.*es)/{if($1~/.*es/)print$1,$2; else print$1,$2/1048576"M"}' && echo -e "\nMysql Mem suggested settings :" && mysql -Bse 'show variables like "datadir";'|awk '{print $2}'|xargs -I{} find {} -type f -printf "%s %f\n"|awk -F'[ ,.]' '{print $1, $NF}'|awk '{array[$2]+=$1} END {for (i in array) {printf("%-15s %s\n", sprintf("%.3f MB", array[i]/1048576), i)}}' | awk '{if($3~/MYI/)print"key_buffer_size\t\t> ",$1"M"};{if($3~/ibd/)a+=$1}END{print "innodb_buffer_pool_size\t> ",a"M"}')" >> $info1

# Vhost files?
echo -e "\nVirtualhost files: " >> $info1
echo $(find  /usr/local/apache/conf/includes/ -name 'pre*' -name '*.conf' ! -name 'error*' -size +0) >> $info1

# Formatting correction and output to screen 
sed "s/\/usr/\\n\/usr/g" $info1
