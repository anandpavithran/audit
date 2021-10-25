#!/bin/bash
for i in $(ls /sys/class/net|grep e)
do
echo $i `ethtool $i | grep Speed`
done
