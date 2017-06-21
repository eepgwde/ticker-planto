#!/bin/bash -x
# run rdb demo

test -n "$sName" || exit 1

Q=~/q/l32/q
: ${D=$(realpath $(dirname $0))}

cd $D

# load each q process in a new terminal
f() {
    test -f "$2" || return 1
    screen -S $sName -X eval "screen $nN"
    screen -S $sName -X eval "title $1"
    shift
    screen -S $sName -X stuff "$nodo rlwrap $Q $* \n"
    $nodo sleep 0.25
}

# wait for listening port
w() {
    set +e 

    for i in `seq 1 20`; do
	netstat -lnt -A inet | awk 'BEGIN { err0=1 } $1 ~ /tcp/ && $4 ~ /:'$1'$/ { err0=0 } END { exit(err0) }'
	let err0=$?
	if [ $err0 -eq 0 ]
	then
	    break
	fi
	sleep 0.25
    done
    set -e
}

set -e

case $1 in 
 "ticker" ) f "tickerplant" "ticker.q" "-p 5010";w 5010 ;;
 "feed" ) f $1 "$D/feed.q" "localhost:5010 -t 507" ;;
 # Real rdb
 # "rdbr" ) f $1 "$D/r.q" "-p 5011 -t 1000" ;;
 "rdb" ) f $1 "$D/cx.q" $1 "-p 5011 -t 1000" ;;
 "hlcv" ) f $1 "$D/cx.q" "$1 -p 5014 -t 1000" ;;
 "last1" ) f $1 "$D/cx.q" "$1 d -p 5018 -t 1000" ;;
 "last" ) f $1 "$D/cx.q" "$1 -p 5015 -t 1000" ;;
 "tq" ) f $1 "$D/cx.q" "$1 -p 5016 -t 1000" ;;
 "vwap" ) f $1 "$D/cx.q" "$1 -p 5017 -t 1000" ;;
 "show" ) f $1 "$D/cx.q" $1 ;;
 "gtrd") f $1 "$D/gtrd.q" "-p 5019 -t 1000" ;;
esac
