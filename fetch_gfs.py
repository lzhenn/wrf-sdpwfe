#!/usr/bin/python
# -*- coding: UTF-8 -*-
#   Fetch GFS realtime forecast data from HKUST ENVR Server
#   executed every day at 00:30
#       L_Zealot
#       Jan 06, 2018
#
#

import datetime
import os



# Main function

def main():
    
    # Optional URL when data not available from HKUST
    #url='ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.2018010512/'
    
    # Fetch url
    url0='http://envf.ust.hk/dataop/data/model_input/gfs_1.00deg_realtime/'
    url0='http://143.89.115.22/dataop/data/model_input/gfs_1.00deg_realtime/'
    
    # Archive path
    arpath='/home/lzhenn/array/lzhenn/gfs_fcst/'

    date_lastday=datetime.datetime.now()+datetime.timedelta(days=-1)
    date_str=date_lastday.strftime('%Y%m%d')
    
    arpath=arpath+date_str
    os.system('mkdir '+arpath)
    for ii in range(0,168,6):
        filename='gfs.t12z.pgrb2.1p00.f%03d' % ii
        url=url0+'gfs.'+date_str+'12/'+filename
        print('fetching '+url)
        os.system('wget '+url+' -O'+' '+arpath+'/'+filename)
if __name__=='__main__':
    main()
