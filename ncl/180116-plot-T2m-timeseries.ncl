;***********************************************
; Draw T2m at home
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
; Mission1.    Read T2M 
; ==============================================================

    ; home
    lat0=37.40
    lon0=121.56
    wrfout_path="/home/lzhenn/array/lzhenn/WRFV3/run/wrfout_d03*"

    g_fig_name="../fig/T2m-home"
    g_fig_title="T2m @ home"
    g_font=0.018

	all_files = systemfunc ("ls "+wrfout_path)
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	setfileoption("nc","SuppressClose",False) ; close too many files
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)

	ctrl_var1  = wrf_user_getvar(ctrl_in,"T2", -1)  
    ctrl_var1 =(/ctrl_var1 - 273.15/)
    time0 = wrf_user_getvar(ctrl_in,"Times", -1)
    xtime = wrf_times_c( time0, 3 ) 
    xtime = xtime +8
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

    plot = new((/1/),graphic)
    res@gsnFrame         = False
    res@gsnDraw  = False
    res@gsnMaximize           = True 
    ;res@vpXF     = 0.15

    res@vpWidthF = 0.8
    res@vpHeightF= 0.2


    ;res@trYMinF            = 0.9*min(var1_season_scmean)                ; Y axis limits
    ;res@trYMaxF            = 1.1*max(var1_season_scmean)

    ;res@trYMinF            = 3.5                ; Y axis limits
    ;res@trYMaxF            = 6.5
    res@gsnCenterString = g_fig_title
    ;res@trXMaxF  = dimsizes(var1_season_seamean)-1                   ; max value on x-axis
    res@tmXBMode      = "Explicit" ; Define own tick mark labels.
    res@tiYAxisString = "T2m (degC)"
    res@tmXBValues = ispan(0,lentime,24) ;interval
    res@tmXBLabels = xtime(::24)    ;tick label
    res@xyMonoLineColor    = False             ; want colored lines
    res@xyLineColors       = (/"red","black"/) ; colors chosen
    res@xyLineThicknesses    = (/3.0,2.0,2.0,2.0,2.0/)      ; line thicknesses
    res@xyDashPatterns   = (/0.,1.,0.,0.,1./)      ; make all lines solid
    res@tmXBMajorThicknessF = 5.0
    res@tmYLMajorThicknessF = 5.0
    res@tmXBMinorThicknessF = 4.0
    res@tmYLMinorThicknessF = 4.0
    res@tmBorderThicknessF = 4.0
    res@tmXBLabelFontHeightF = g_font
    res@tmYLLabelFontHeightF = g_font
    ; Note that a colon is the default function code. We recommend
    ; setting default code to be a tilde (~) in your .hluresfile.
    ; See: http://www.ncl.ucar.edu/Document/Graphics/hlures.shtml


    ;plot(0)  = gsn_csm_xy (wks,ispan(0,dimsizes(var1_season_scmean)-1,1),data,res)   ; create plot
    
    res@tiXAxisString = "Time"
   ;res@trYMinF            = 9*min(var1_season_seamean)                ; Y axis limits
    ;res@trYMaxF            = 1.1*max(var1_season_seamean)
    plot(0)  = gsn_csm_xy (wks, ispan(0,lentime-1,1),ctrl_var1(:,cor_x,cor_y),res)   ; create plot
    draw(plot)
    frame(wks)

end
