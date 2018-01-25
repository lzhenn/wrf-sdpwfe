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

    ; home
    lat0=37.40
    lon0=121.56
    wrfout_path="/home/lzhenn/array/lzhenn/WRFV3/run/wrfout_d03*"

    g_fig_name="../fig/T2m-home"
    g_font=0.012
    
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)

	all_files = systemfunc ("ls "+wrfout_path)
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	setfileoption("nc","SuppressClose",False) ; close too many files
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)

	ctrl_var1_0  = wrf_user_getvar(ctrl_in,"TSK", -1)  
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
    point=getind_latlon2d(lat2d,lon2d,lat0,lon0)
    cor_x=point(0,0)
    cor_y=point(0,1)
;**********************************************************************************************
;MISSION.3      Display timeseries 
;**********************************************************************************************

  
	
	wks = gsn_open_wks("png","../fig/T2m-home")       ; open file to plot 


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


    res@trYMinF            = min(ctrl_var1(:,cor_x,cor_y))-2                ; Y axis limits
    res@trYMaxF            = max(ctrl_var1(:,cor_x,cor_y))+2
    res@tmXBOn = True 
    res@tmXBMinorOn = False
    res@tmXTOn = False
    ;res@trYMinF            = 3.5                ; Y axis limits
    ;res@trYMaxF            = 6.5
    ;res@trXMaxF  = dimsizes(var1_season_seamean)-1                   ; max value on x-axis
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
    plot(0)  = gsn_csm_xy2 (wks, ispan(0,lentime-1,1),ctrl_var1(:,cor_x,cor_y),ctrl_var4(:,cor_x,cor_y),res, resR)   ; create plot
    
    res_line=True
    res_line@gsLineDashPattern=1.
    do ii=0, lentime-1
        if mod(ii-4, 24) .eq. 0 then 
            str=unique_string("")
            plot@$str$=gsn_add_polyline(wks,plot(0),(/ii,ii/),(/res@trYMinF, res@trYMaxF/),res_line)
        end if
    end do



    ctrl_var5  = wrf_user_getvar(ctrl_in,"SNOWH", -1)  
    ctrl_var6  = wrf_user_getvar(ctrl_in,"RAINC", -1)  
	ctrl_var7  = wrf_user_getvar(ctrl_in,"RAINNC", -1)  
    
    ctrl_var5  = ctrl_var5*100
    ctrl_var6  = (ctrl_var6+ctrl_var7)
    ctrl_var6(1:lentime-1,:,:)=ctrl_var6(1:lentime-1,:,:)-ctrl_var6(0:lentime-2,:,:)
;    ctrl_var5(1:lentime-1,:,:)=ctrl_var5(1:lentime-1,:,:)-ctrl_var5(0:lentime-2,:,:)
    res_snow = res
    res_snow@tiYAxisString = "Snow Depth (mm)"
   
    res_snow@vpHeightF= 0.1
    res_snow@vpWidthF = 0.8
    res_snow@xyLineColors := (/"black"/)
    res_snow@trYMinF            = 0                ; Y axis limits
    res_snow@trYMaxF            = max(ctrl_var5(:,cor_x,cor_y))+0.1
    res_snow@gsnXYBarChart=True
    res_snow@gsnXYBarChartBarWidth = 1.0                 ; change bar widths
    res_snow@gsnXYBarChartColors := (/"grey"/)             ; below ref line fill blue
    res_pr=res_snow
    res_pr@tiYAxisString= "Pr (mm/hr)"
    res_pr@trYMaxF=max(ctrl_var6(:,cor_x,cor_y))+0.1
    res_pr@gsnXYBarChartColors := (/"skyblue"/)             ; below ref line fill blue
    plot(1)  = gsn_csm_xy2 (wks, ispan(0,lentime-1,1),ctrl_var5(:,cor_x,cor_y),ctrl_var6(:,cor_x,cor_y),res_snow, res_pr)   ; create plot
    do ii=0, lentime-1
        if mod(ii-4, 24) .eq. 0 then 
            str=unique_string("")
            plot@$str$=gsn_add_polyline(wks,plot(1),(/ii,ii/),(/res_snow@trYMinF, res_snow@trYMaxF/),res_line)
        end if
    end do
    
    gsn_panel(wks, plot, (/2,1/), False)

end
