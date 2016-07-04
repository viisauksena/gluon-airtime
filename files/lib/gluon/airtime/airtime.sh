#!/bin/sh 
# Setup once at runtime ...
# ... after at least 5 minutes of uptime have passed:
uptime=`awk </proc/uptime 'BEGIN{uptime=0;} {uptime=sprintf("%d", $1);} END{print uptime;}'`
if [ $uptime -lt 300 ]; then
  echo "Waiting to pass 300 seconds of uptime for stabilizing."
  exit 0
fi

# get actual airtime
channel=$(iw client0 survey dump |grep "in use" -A5|grep -o "24.."|head -n1)
total=$(iw client0 survey dump |grep "in use" -A5|grep active|grep -o "[0-9]*")
tx=$(iw client0 survey dump |grep "in use" -A5|grep transmit|grep -o "[0-9]*")
busy=$(iw client0 survey dump |grep "in use" -A5|grep busy|grep -o "[0-9]*")

mkdir -p /tmp/xtra
if [ ! -f /tmp/2gtotallast ]; then echo 0 > /tmp/2gtotallast; fi
if [ ! -f /tmp/2gtxlast ]; then echo 0 > /tmp/2gtxlast; fi
if [ ! -f /tmp/2gbuslast ]; then echo 0 > /tmp/2gbuslast; fi

# calc airtime to file
echo $(( $total - $(cat /tmp/2gtotallast|tail -n1) )) > /tmp/xtra/2gtotal
echo $(( $tx - $(cat /tmp/2gtxlast|tail -n1) )) > /tmp/xtra/2gtx
echo $(( $busy - $(cat /tmp/2gbuslast|tail -n1) )) > /tmp/xtra/2gbus

# calc24h avg max min
sumtotal=0
date +%M |grep [0-5]0 && for line in $(cat /tmp/xtra/2gtotal24h); do let sumtotal+=$line; done 
date +%M |grep [0-5]0 && echo $(( $sumtotal / $(cat /tmp/xtra/2gtotal24h|wc -l) )) > /tmp/xtra/2gtotal24havg
cat /tmp/xtra/2gtotal24h|sort -n |head -n1 > /tmp/xtra/2gtotal24hmin
cat /tmp/xtra/2gtotal24h|sort -n |tail -n1 > /tmp/xtra/2gtotal24hmax
sumtx=0
date +%M |grep [0-5]0 && for line in $(cat /tmp/xtra/2gtx24h); do let sumtx+=$line; done
date +%M |grep [0-5]0 && echo $(( $sumtx / $(cat /tmp/xtra/2gtx24h|wc -l) )) > /tmp/xtra/2gtx24havg
cat /tmp/xtra/2gtx24h|sort -n|head -n1 > /tmp/xtra/2gtx24hmin
cat /tmp/xtra/2gtx24h|sort -n|tail -n1 > /tmp/xtra/2gtx24hmax
sumbus=0
date +%M |grep [0-5]0 && for line in $(cat /tmp/xtra/2gbus24h); do let sumbus+=$line; done
date +%M |grep [0-5]0 && echo $(( $sumbus / $(cat /tmp/xtra/2gbus24h|wc -l) )) > /tmp/xtra/2gbus24havg
cat /tmp/xtra/2gbus24h|sort -n|head -n1 > /tmp/xtra/2gbus24hmin
cat /tmp/xtra/2gbus24h|sort -n|tail -n1 > /tmp/xtra/2gbus24hmax

# write act to tmp file,
echo $total > /tmp/2gtotallast
echo $tx > /tmp/2gtxlast
echo $busy > /tmp/2gbuslast

# write and limit to 24h (=1440 lines per file)
echo $((($channel - 2407 )/ 5)) > /tmp/xtra/channel
cat /tmp/xtra/2gtotal >> /tmp/xtra/2gtotal24h ; cat /tmp/xtra/2gtotal24h |tail -n 1440 > /tmp/2gtotaltmp ; mv /tmp/2gtotaltmp /tmp/xtra/2gtotal24h
cat /tmp/xtra/2gtx >> /tmp/xtra/2gtx24h ; cat /tmp/xtra/2gtx24h |tail -n 1440 > /tmp/2gtxtmp ; mv /tmp/2gtxtmp /tmp/xtra/2gtx24h
cat /tmp/xtra/2gbus >> /tmp/xtra/2gbus24h; cat /tmp/xtra/2gbus24h |tail -n 1440 > /tmp/2gbustmp ; mv /tmp/2gbustmp /tmp/xtra/2gbus24h

# bonus
batctl gwl |grep = |cut -d")" -f1|grep -o [0-9]*$ > /tmp/xtra/batttvn
batctl gwl |grep = |cut -d"]" -f1|grep -o [0-9a-zA-Z_-]*$ > /tmp/xtra/batif

