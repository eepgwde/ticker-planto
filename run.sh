#!/bin/bash
# run rdb demo

: ${d_services=$*}
: ${d_services=ticker rdb hlcv last tq show vwap feed}

D=$(realpath $(dirname $0))
export D

P=$D/run1.sh

screen -S ticker-$$ -d -m
export sName=ticker-$$
let nN=0
export nN

# for f in ticker rdb hlcv last tq show vwap feed
for f in $d_services
do
    $P $f;
    let nN=nN+1
done
