#!/bin/bash

# -------------------------
# Output DNS data:
# -------------------------

read -p "What is the domain? " domain
echo 
echo -e "DOMAIN: $domain\n" 
echo -e "REGISTRAR:\n"
if [ "$(expr match "$domain" '.*\.\(.*\..*\)')" == "$domain" ] 
  then
  whois $domain | egrep "Registrar( URL:|:)"|awk '{print $1,$2,$3,$4,$5,$6}' | sort | uniq
  else 
  whois $(expr match "$domain" '.*\.\(.*\..*\)')| egrep "Registrar( URL:|:)"|awk '{print $1,$2,$3,$4,$5,$6}' | sort | uniq
fi
echo
echo -e "NAME SERVERS:\n"
if [ "$(expr match "$domain" '.*\.\(.*\..*\)')" == "$domain" ]
  then
  whois $domain |grep "Name Server:"|awk '{print $3}'|xargs dig|grep IN|grep -v ";"|awk '{print $1" " $5}' | sort | uniq
  else
  whois $(expr match "$domain" '.*\.\(.*\..*\)')|grep "Name Server:"|awk '{print $3}'|xargs dig|grep IN|grep -v ";"|awk '{print $1" " $5}' | sort | uniq
  fi
echo
echo -e "A Records:\n"
dig A $domain|grep IN|grep -v ";"|awk '{print $1" " $5}' | sort | uniq
echo 
echo -e "MX Records:\n"
dig MX $domain | grep IN|grep -v ";"|awk '{print$6}'|xargs dig A |grep IN|grep -v ";"|awk '{print $1" " $5}' | sort | uniq| grep -v "root-servers" 
