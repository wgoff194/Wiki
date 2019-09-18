#!/bin/bash

# -------------------------
# Output DNS data:
# -------------------------

read -p "What is the domain? " domain
echo 
echo -e "DOMAIN: $domain\n" 
echo -e "REGISTRAR:\n"  
whois $domain | egrep "Registrar( URL:|:)"|awk '{print $1,$2,$3,$4,$5,$6}' 
echo
echo -e "NAME SERVERS:\n"
whois $domain|grep "Name Server:"|awk '{print $3}'|xargs dig|grep IN|grep -v ";"|awk '{print $1" " $5}'
echo
echo -e "A Records:\n"
dig A $domain|grep IN|grep -v ";"|awk '{print $1" " $5}'
echo 
echo -e "MX Records:\n"
dig MX $domain|grep IN|grep -v ";"|awk '{print$6}'|xargs dig A |grep IN|grep -v ";"|awk '{print $1" " $5}'
