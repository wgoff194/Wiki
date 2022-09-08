## Log Diving Older Plesk

```
/var/www/vhosts/*/logs/ (Old, before daily log rollover)
```
#### Most requests in a provided window
```
(echo; read -p "Start time (01/Jan/2019:00:00): " stime; read -p "End time (01/Jan/2019:00:00): " etime;  for x in $(find /var/www/vhosts/*/logs/ -type f -name access*.gz); do if grep -q $stime <(gzip -dc $x) ; then  echo -e "$(awk -v s="$stime" -v e="$etime" '/'"$s"'/,/'"$e"'/'<(gzip -dc $x) | wc -l) \t$x" ; fi; done) | sort -nr | grep -v '^0 '
```
#### IP Access in a provided window
```
(echo; read -p "Primary Domain: " user; read -p "Start time (01/Jan/2019:00:00): " stime; read -p "End time (01/Jan/2019:00:00): " etime;  for x in $(find /var/www/vhosts/$user/logs/ -type f -name access*.gz); do if grep -q $stime <(gzip -dc $x) ; then  echo -e "\n\n$x\n"; awk -v s="$stime" -v e="$etime" '/'"$s"'/,/'"$e"'/' <(gzip -dc $x)| awk '{print $1}' | sort | uniq -c | sort -nr ; fi ; done)
```
#### POST requests in a provided window

```
(echo; read -p "Primary Domain: " user; read -p "Start time (01/Jan/2019:00:00): " stime; read -p "End time (01/Jan/2019:00:00): " etime;  for x in $(find /var/www/vhosts/$user/logs/ -type f -name access*.gz); do if grep -q $stime <(gzip -dc $x) ; then echo -e "\n\n$x\n"; awk -v s="$stime" -v e="$etime" '/'"$s"'/,/'"$e"'/' <(gzip -dc $x)| grep POST | awk -F'\"' '{print $2}' | sort | uniq -c | sort -nr; fi ; done)
```
