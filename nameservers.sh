#!/bin/bash

# -------------------------
# Output DNS data:
# -------------------------

read -p "What is the domain? " domain
echo 
echo -e "DOMAIN: $domain\n" 
echo -e "REGISTRAR:\n"  
whois $(expr match "$domain" '.*\.\(.*\..*\)')| egrep "Registrar( URL:|:)"|awk '{print $1,$2,$3,$4,$5,$6}' | sort | uniq
echo
echo -e "NAME SERVERS:\n"
whois $(expr match "$domain" '.*\.\(.*\..*\)')|grep "Name Server:"|awk '{print $3}'|xargs dig|grep IN|grep -v ";"|awk '{print $1" " $5}' | sort | uniq
echo
echo -e "A Records:\n"
dig A $domain|grep IN|grep -v ";"|awk '{print $1" " $5}' | sort | uniq
echo 
echo -e "MX Records:\n"
dig MX $domain|grep IN|grep -v ";"|awk '{print$6}'|xargs dig A |grep IN|grep -v ";"|awk '{print $1" " $5}' | sort | uniq | grep -v root-servers
