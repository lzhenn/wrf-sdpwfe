for((I=0;I<=24;I++))
do
    TF=$(expr $I \* 3)
    TFSTMP=`printf "%.3d" $TF`
    convert -trim +repage -bordercolor white -background white -flatten snow-cover_${TFSTMP}H.png snow-cover_${TFSTMP}H.png
done
