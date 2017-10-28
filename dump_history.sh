#!/bin/sh

read line
d=$(date '+%b %d %H:%M:%S')
echo "$HOSTNAME $d - $PWD - $line" >> ~/history/history.txt
