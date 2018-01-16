#!/usr/bin/python
# -*- coding: UTF-8 -*-
#   Fetch GFS realtime forecast data from HKUST ENVR Server
#   executed every day at 00:30
#       L_Zealot
#       Jan 06, 2018
#
#

import datetime
import requests 
import os



# Main function

def main():
    
    # Optional URL when data not available from HKUST
    #url='ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.2018010512/'
    
    # Fetch url
    url0='ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/sst.'
    
    # Archive path
    arpath='/home/lzhenn/array/lzhenn/gfs_fcst/'

    # for fetch path
    date_lastday=datetime.datetime.now()+datetime.timedelta(days=-1)
    date_str=date_lastday.strftime('%Y%m%d')
    
    # for archive dir
    date0_lastday=datetime.datetime.now()+datetime.timedelta(days=-1)
    date0_str=date0_lastday.strftime('%Y%m%d')
    arpath=arpath+date0_str+'/rtgssthr_grb_0.083.grib2'


    url=url0+date_str+'/rtgssthr_grb_0.083.grib2'

    print('fetching '+url)
    os.system('wget '+url+' -O'+' '+arpath)
if __name__=='__main__':
    main()
