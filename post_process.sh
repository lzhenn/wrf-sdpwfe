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
ncl 180207-plot-T2m.ncl
ncl 180207-plot-RH2m.ncl
ncl 180207-plot-UV10m.ncl

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
convert -delay 100 T2m_* T2m.gif
convert -delay 100 RH2m_* RH2m.gif
convert -delay 100 Wind10m_* Wind10m.gif

# Move realtime figures to repo
cp T2m-home.png $TS_DIR 
mv snow-cover_* $MAP_DIR
mv precip_* $MAP_DIR
mv T2m_* $MAP_DIR
mv RH2m_* $MAP_DIR
mv Wind10m_* $MAP_DIR

cd $WORKDIR
sh gitfresh.sh 
