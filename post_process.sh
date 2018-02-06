#!/bin/sh

WORKDIR=/home/lzhenn/workspace/wrf-sdpwfe
FIG_REPO=/home/lzhenn/array/lzhenn/wrf-sdpwfe-fig

LID=`date -d '1 days ago' +%Y%m%d`

TS_DIR=$FIG_REPO/timeseries/$LID
MAP_DIR=$FIG_REPO/maps/$LID

mkdir $TS_DIR
mkdir $MAP_DIR


cd $WORKDIR/ncl
ncl 180124-plot-T2m-RH-timeseries.ncl 
cd $WORKDIR/fig


# Cut borders
convert T2m-home.png -bordercolor white -trim T2m-home.png


# Move realtime figures to repo
cp T2m-home.png $TS_DIR 

cd $WORKDIR
sh gitfresh.sh 
