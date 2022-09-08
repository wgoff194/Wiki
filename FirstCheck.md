### First Server Check

```
(info1=/home/$(hostname)-$(date +"%F-%T".txt); touch $info1;echo -e "\nDate: $(date)\n\nHostname: $(hostname)\n\n$(cat /etc/centos-release)\n\nCores: $(nproc)\n\n$(w)\n\n$(free -m)\n\n$(df -h| grep -v tmpfs)\n\nApache info:\n$(httpd -V|head -9|grep -E '(version|built|MPM)')\n$(if  find  /usr/local/apache/conf/includes/ -name 'pre*' -name '*.conf' ! -name 'error*' -size +0 -exec true {} + ; then echo -e "\nVirtualhost files:\n$(find  /usr/local/apache/conf/includes/ -name 'pre*' -name '*.conf' ! -name 'error*' -size +0)"; fi)\n\nEA4: $(if [ -f /etc/cpanel/ea4/is_ea4 ]; then echo 'Yes'; else echo 'No'; fi)\n\ncPanel backups:\n$(grep --color=never -i "enable\|dir\|retent" /var/cpanel/backups/config)\n\nPHP info: \n$(/usr/local/cpanel/bin/rebuild_phpconf --current)\n\n$(grep -Ei 'memory_li|(post|upload)_max' /opt/cpanel/ea-php*/root/etc/php.ini)\n$(if [[ -f /etc/cpanel/ea4/is_ea4 && ! -z `find /opt/cpanel/ea-php*/root/etc/php.d/ -name ssp.ini` ]]; then echo -e "\n\nSS+ PHP INIs:\n$(find /opt/cpanel/ea-php*/root/etc/php.d/ -name ssp.ini)";fi)\n\nMySQL info:">> $info1; echo -e "$(echo -e "\nMysql Mem configured settings: " && awk '/(key|i.*b)_b.*r_(pool_)?(s.*|.*es)/{sub("="," "); print $1,$2}' /etc/my.cnf && echo -e "\nMysql Mem current settings: " && mysql -e "show variables" |awk '/(key|innodb)_buffer_(pool_)?(size|.*es)/{if($1~/.*es/)print$1,$2; else print$1,$2/1048576"M"}' && echo -e "\nMysql Mem suggested settings :" && mysql -Bse 'show variables like "datadir";'|awk '{print $2}'|xargs -I{} find {} -type f -printf "%s %f\n"|awk -F'[ ,.]' '{print $1, $NF}'|awk '{array[$2]+=$1} END {for (i in array) {printf("%-15s %s\n", sprintf("%.3f MB", array[i]/1048576), i)}}' | awk '{if($3~/MYI/)print"key_buffer_size\t\t> ",$1"M"};{if($3~/ibd/)a+=$1}END{print "innodb_buffer_pool_size\t> ",a"M"}')" >> $info1; cat $info1)
```

#### Output example:

```
Hostname: host.warrengbrown.com

CentOS Linux release 7.6.1810 (Core) 

Cores: 2

 17:50:09 up 214 days, 17:26,  1 user,  load average: 0.00, 0.01, 0.05
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
lwadmin- pts/0    10.30.4.131      17:49    1.00s  0.17s  0.01s sshd: lwadmin-S7AEQ5 [priv]

              total        used        free      shared  buff/cache   available
Mem:            956         441          70          56         444         295
Swap:          1999         944        1055

Filesystem      Size  Used Avail Use% Mounted on
/dev/vda3        48G   14G   32G  31% /
/dev/loop0      1.9G   30M  1.7G   2% /tmp

Apache info:
Server version: Apache/2.4.39 (cPanel)
Server built:   May 24 2019 18:51:15
Server MPM:     event

EA4: Yes

PHP info: 
DEFAULT PHP: ea-php70
ea-php55 SAPI: cgi
ea-php56 SAPI: cgi
ea-php70 SAPI: cgi
ea-php71 SAPI: cgi
ea-php72 SAPI: cgi

MySQL info:

Mysql Mem configured settings: 
innodb_buffer_pool_size 128M
innodb_buffer_pool_instances 1
key_buffer_size 64M

Mysql Mem current settings: 
innodb_buffer_pool_instances 1
innodb_buffer_pool_size 128M
key_buffer_size 64M

Mysql Mem suggested settings :
key_buffer_size     >  0.721M
innodb_buffer_pool_size >  85.781M

Virtualhost files:
/usr/local/apache/conf/includes/pre_main_global.conf
/usr/local/apache/conf/includes/pre_virtualhost_global.conf
```
