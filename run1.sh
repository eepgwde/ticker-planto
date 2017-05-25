#!/bin/bash -x
# run rdb demo

test -n "$sName" || exit 1

Q=~/q/l32/q
: ${D=$(realpath $(dirname $0))}

cd $D

# load each q process in a new terminal
f() {
    test -f "$2" || ( echo "fail: $2"; return 1)
    screen -S $sName -X eval "screen $nN"
    screen -S $sName -X eval "title $1"
    screen -S $sName -X stuff "$nodo rlwrap $Q $2\n"
    $nodo sleep 0.25
}

# wait for listening port
w() {
for i in `seq 1 20`; do
  S=`netstat -lnt -A inet | grep ":$1"`
  if [ -n "$S" ]; then return 0; fi; sleep 0.25
done
}

case $1 in 
 "ticker" ) f "tickerplant" "ticker.q -p 5010";w 5010 ;;
 "rdb" ) f $1 "$D/r.q -p 5011 -t 1000" ;;
 "hlcv" ) f $1 "$D/cx.q $1 -p 5014 -t 1000" ;;
 "last" ) f $1 "$D/cx.q $1 -p 5015 -t 1000" ;;
 "tq" ) f $1 "$D/cx.q $1 -p 5016 -t 1000" ;;
 "vwap" ) f $1 "$D/cx.q $1 -p 5017 -t 1000" ;;
 "show" ) f $1 "$D/cx.q $1" ;;
 "feed" ) f "feed" "$D/feed.q localhost:5010 -t 507" ;;
esac
