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
ncl 180205-plot-snow-cover.ncl
ncl 180205-plot-precip.ncl

cd $WORKDIR/fig


# Cut borders
convert T2m-home.png -bordercolor white -trim T2m-home.png


#for((I=0;I<=31;I++))
#do
#    TF=$(expr $I \* 3)
#    TFSTMP=`printf "%.3d" $TF`
#    convert snow-cover_${TFSTMP}H.png -bordercolor white -trim snow-cover_${TFSTMP}H.png
#done

# convert gif
convert -delay 100 snow-cover_* snow-cover.gif
convert -delay 100 precip_* precip.gif

# Move realtime figures to repo
cp T2m-home.png $TS_DIR 
cp snow* $MAP_DIR
cp precip* $MAP_DIR

rm -f snow-cover_*
rm -f precip_*

cd $WORKDIR
sh gitfresh.sh 
