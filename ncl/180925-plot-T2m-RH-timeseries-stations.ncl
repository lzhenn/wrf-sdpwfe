;***********************************************
; Draw T2m i& RH2M at home
;
; jobs:
;   1.Read wrfout03 T2 var
;   2.Display the Result
;                       L_Zealot
;                       2018-01-16
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
begin
; ==============================================================
; Mission1.    Read Var
;
;   var1        T2
;   var2        Q2
;   var3        Surface Presure
;   var4        RH2
;
;   var5        SNOWH
;   var6        RAINC
;   var7        RAINNC
; ==============================================================

    ; station info
    sta_names=(/"Home","Central","Seaside Farm","Airport"/)
    lat_list=(/  37.40,   37.53,  37.45,  37.66/)
    lon_list=(/ 121.56,  121.39, 121.72, 120.99/)
    
    n_sta=dimsizes(sta_names)

    wrfout_path="/home/lzhenn/array/lzhenn/WRFV3/run/wrfout_d03*"

    g_fig_name="../fig/T2m-seaside"
    g_font=0.012
    
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)

	all_files = systemfunc ("ls "+wrfout_path)
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	setfileoption("nc","SuppressClose",False) ; close too many files
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)

	ctrl_var1_0  = wrf_user_getvar(ctrl_in,"T2", -1)  
	ctrl_var2  = wrf_user_getvar(ctrl_in,"Q2", -1)  
	ctrl_var3  = wrf_user_getvar(ctrl_in,"PSFC", -1)  
    
    ; get rh2m
    ctrl_var4  = wrf_rh(ctrl_var2, ctrl_var3, ctrl_var1_0)

    ctrl_var1 =(/ctrl_var1_0 - 273.15/)
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

   date_str = month_abbr(month(4::12))+sprinti(" %0.2i~C~", day(4::12)) + sprinti("%0.2iH", hour(4::12)) 
              


    lentime=dimsizes(xtime)
    lat2d = wrf_user_getvar(ctrl_in,"XLAT",  1)
    lon2d = wrf_user_getvar(ctrl_in,"XLONG", 1)
    ctrl_var1@lat2d = lat2d
    ctrl_var1@lon2d = lon2d
   
    ; point(i,j) --- i -> sta_list; j -> 0:x; 1:y.
    point=getind_latlon2d(lat2d,lon2d,lat_list,lon_list)
    
    lb_bot=lat_list
    lb_top=lon_list
    
    do ii = 0, n_sta-1
        lb_bot(ii)=min(ctrl_var1(:,point(ii,0),point(ii,1)))-2
        lb_top(ii)=max(ctrl_var1(:,point(ii,0),point(ii,1)))+2
    end do
;**********************************************************************************************
;MISSION.3      Display timeseries 
;**********************************************************************************************

  
	
	wks = gsn_open_wks("x11","../fig/T2m-home")       ; open file to plot 


    ;************************************************ 
    ; plotting parameters
    ;************************************************

    res               = True                    ; plot mods desired

    plot = new((/2/),graphic)
    res@gsnFrame         = False
    res@gsnDraw  = False
    res@gsnMaximize           = True 
    res@vpXF     = 0.15

    res@vpWidthF = 0.8
    res@vpHeightF= 0.2


    res@trYMinF            = min(lb_bot)                ; Y axis limits
    res@trYMaxF            = max(lb_top)
    res@tmXBOn = True 
    res@tmXBMinorOn = False
    res@tmXTOn = False
    ;res@trYMinF            = 3.5                ; Y axis limits
    ;res@trYMaxF            = 6.5
    res@trXMaxF  = lentime-1                   ; max value on x-axis
    res@tiYAxisFontHeightF=g_font
    res@tiYAxisString = "T2m (degC)"
    res@xyMonoLineColor    = False             ; want colored lines
    res@xyLineColors       = (/"red","black"/) ; colors chosen
    res@xyLineThicknesses    = (/3.0,2.0,2.0,2.0,2.0/)      ; line thicknesses
    res@xyDashPatterns   = (/0.,1.,0.,0.,1./)      ; make all lines solid
    res@tmYLMinorOn = False
    res@tmYLMajorLengthF = 0.0
    res@tmYRMinorOn = False
    res@tmXBMajorThicknessF = 3.0
    res@tmYLMajorThicknessF = 3.0
    res@tmXBMinorThicknessF = 2.0
    res@tmYLMinorThicknessF = 2.0
    res@tmBorderThicknessF = 2.0
    
    res@tmXBMode = "Explicit"
    res@tmXBValues=ispan(4, lentime-1,12)
    res@tmXBLabels=date_str

    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    
    resR=res
    delete([/resR@trYMinF, resR@trYMaxF, resR@tiYAxisString/])
    resR@xyLineColors:="darkgreen"
    resR@tiYAxisString="RH (%)"
    plot(0)  = gsn_csm_xy (wks, ispan(0,lentime-1,1),ctrl_var1(:,cor_x,cor_y),res)   ; create plot
    
    res_line=True
    res_line@gsLineDashPattern=1.
    do ii=0, lentime-1
        if mod(ii-4, 24) .eq. 0 then 
            str=unique_string("")
            plot@$str$=gsn_add_polyline(wks,plot(0),(/ii,ii/),(/res@trYMinF, res@trYMaxF/),res_line)
        end if
    end do

    str=unique_string("")
    plot@$str$=gsn_add_polyline(wks,plot(0),(/ii,ii/),(/res@trYMinF, res@trYMaxF/),res_line)

end
