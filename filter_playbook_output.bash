#!/bin/bash

for log in *vlan_group_*check*.log; do
  echo $log
  printf "=%.0s" $(seq 1 ${#log})
  echo
  awk '/TASK \[Check if VLANs found\]/,/^$/' $log \
   | fgrep -A 2 fatal | egrep -o '\[.*\]| No ports in vlans.*' \
   | sed ':a; N; $!b a; s/\n\s\{1,\}/ /g'

  awk '/TASK \[Show config commands to be executed\]/,/^$/' $log \
    | egrep -v '^[[:space:]]*$' \
    | awk 'BEGIN { RS="ok:"; FS="\n" } { if (NF > 4) print $0 }'

  awk '/TASK \[.*compliance check #1\]/,/^$/' $log \
   | fgrep -A 2 fatal | egrep -o '\[.*\]| Missing vlan group.*' \
   | sed ':a; N; $!b a; s/\n\s\{1,\}/ /g'


  awk '/TASK \[.*compliance check #2\]/,/^$/' $log \
   | fgrep -A 4 fatal | egrep -o '\[.*\]|- .*' \
   | sed ':a; N; $!b a; s/\n-\s\{1,\}/ /g'

  echo
done
