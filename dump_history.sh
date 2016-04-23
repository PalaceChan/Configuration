#!/bin/sh

read line
d=$(date '+%b %d %H:%M:%S')
echo "$d - $line" >> ~/history/history.txt
