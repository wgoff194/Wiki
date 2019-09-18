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
rminfo1="n"
echo -e "\nTemp file location: $info1"
touch $info1

# -------------------------
# Output server data start:
# -------------------------

# Output hostname:
echo -e "Hostname: $(hostname)\n" >> $info1

# Output version of OS
echo -e "$(cat /etc/centos-release)\n" >> $info1

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

# Panel Backups
echo -e "Panel backups:\n$(grep --color=never -i "enable\|dir\|retent" /var/cpanel/backups/config)\n" >> $info1

# Ouput Apache info
echo -e "Apache info:\n$(httpd -V|head -9)\n" >> $info1

# Output PHP info
echo -e "PHP info: \n$(/usr/local/cpanel/bin/rebuild_phpconf --current)\n" >> $info1

# PHP SS+
if [[ -f /etc/cpanel/ea4/is_ea4 && ! -z `find /opt/cpanel/ea-php*/root/etc/php.d/ -name ssp.ini` ]]
    then echo -e "SS+ PHP INIs:\n$(find /opt/cpanel/ea-php*/root/etc/php.d/ -name ssp.ini)\n" >> $info1
fi

# Output mysql info 
echo -e "MySQL info:\n" >> $info1
echo -e "Mysql Mem configured settings: " >> $info1
awk '/(key|i.*b)_b.*r_(pool_)?(s.*|.*es)/{sub("="," "); print $1,$2}' /etc/my.cnf  >> $info1
echo -e "\nMysql Mem current settings: "  >> $info1
mysql -e "show variables" |awk '/(key|innodb)_buffer_(pool_)?(size|.*es)/{if($1~/.*es/)print$1,$2; else print$1,$2/1048576"M"}' >> $info1
echo -e "\nMysql Mem suggested settings :" >> $info1
mysql -Bse 'show variables like "datadir";'|awk '{print $2}'|xargs -I{} find {} -type f -printf "%s %f\n"|awk -F'[ ,.]' '{print $1, $NF}'|awk '{array[$2]+=$1} END {for (i in array) {printf("%-15s %s\n", sprintf("%.3f MB", array[i]/1048576), i)}}' | awk '{if($3~/MYI/)print"key_buffer_size\t\t> ",$1"M"};{if($3~/ibd/)a+=$1}END{print "innodb_buffer_pool_size\t> ",a"M"}' >> $info1

# Vhost files?
if  find  /usr/local/apache/conf/includes/ -name 'pre*' -name '*.conf' ! -name 'error*' -size +0 -exec true {} + 
    then 
        echo -e "\nVirtualhost files: " >> $info1
        echo $(find  /usr/local/apache/conf/includes/ -name 'pre*' -name '*.conf' ! -name 'error*' -size +0) >> $info1
fi    

# Formatting correction and output to screen 
sed "s/\/usr/\\n\/usr/g" $info1

# Add blank line
echo -e "\n"

# Remove temp file
while true
do 
    read -r -p "Remove temp file $info1 ?: Yes(default) or No " response   
    if [[ $response =~ ^([nN][oO])$ ]]
    then    
        echo -e "\n $info1 not removed\n"
        break
    else
        rm $info1
	echo -e "\n $info1 removed\n"
	break
    fi
done 
