#!/bin/sh

WORKDIR=/home/lzhenn/workspace/wrf-sdpwfe

cd $WORKDIR/ncl
ncl 180116-plot-T2m-timeseries.ncl
cd $WORKDIR/fig
convert T2m-home.png -bordercolor white -trim T2m-home.png
cd $WORKDIR
sh gitfresh.sh 
