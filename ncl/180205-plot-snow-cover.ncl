;*******************************************************
; lcnative_2.ncl
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
begin
;************************************************
; open file and read in data
;************************************************
    lat0=37.40
    lon0=121.56
 
    wrfout_path="/home/lzhenn/array/lzhenn/WRFV3/run/wrfout_d03*"
    g_fig_name="../fig/snow_cover"
    g_font=0.012
    
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)

   
	all_files = systemfunc ("ls "+wrfout_path)
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	setfileoption("nc","SuppressClose",False) ; close too many files
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)
    
    ; get rh2m
    ctrl_var1  = wrf_user_getvar(ctrl_in,"SNOWH", -1)  
    
    ctrl_var1=ctrl_var1*100
    time0 = wrf_user_getvar(ctrl_in,"Times", -1)
    xtime = wrf_times_c( time0, 1 ) 
    xtime = xtime+8 

    lc_date=cd_calendar(xtime, 0)
    year   = tointeger(lc_date(:,0))    ; Convert to integer for
    month  = tointeger(lc_date(:,1))    ; use sprinti 
    day    = tointeger(lc_date(:,2))
    hour   = tointeger(lc_date(:,3))
    minute = tointeger(lc_date(:,4))
    second = lc_date(:,5)

   date_str = month_abbr(month(4::12))+sprinti(" %0.2i ", day(4::12)) + sprinti("%0.2iH", hour(4::12)) 
              


    lentime=dimsizes(xtime)
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  1)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 1)
    ctrl_var1@lat2d = lat2d
    ctrl_var1@lon2d = lon2d
    point=getind_latlon2d(lat2d,lon2d,lat0,lon0)
    cor_x=point(0,0)
    cor_y=point(0,1)

;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("x11","lcnative")      ; send graphics to PNG file

  res                   = True              ; plot mods desired
;---Resources for filled contour plot
  res                      = True

  res@gsnMaximize          = True

  res@cnFillOn             = True  
  res@cnLinesOn            = False
  res@cnLevelSpacingF      = 2.           ; NCL chose 4.0
  res@lbOrientation        = "Vertical"

;---Necessary for contours to be overlaid correctly on WRF projection
  res@tfDoNDCOverlay       = True
  res@gsnAddCyclic         = False

;---Set map resources based on projection on WRF output file
  res = wrf_map_resources(ctrl_in[0],res)

;---Call plotting routine which draws contours over a map
  nl   = 0    ; bottomost level
  plot = gsn_csm_contour_map(wks,ctrl_var1(48,:,:),res)

end
