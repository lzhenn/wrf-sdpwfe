;**************************************
;  meteo_1.ncl
;
; Concepts illustrated:
;   - Drawing a meteogram
;   - Creating a color map using RGB triplets
;   - Reversing the Y axis
;   - Explicitly setting tickmarks and labels on the bottom X axis
;   - Increasing the thickness of contour lines
;   - Drawing wind barbs
;   - Drawing a bar chart
;   - Changing the width and height of a plot
;   - Overlaying wind barbs and line contours on filled contours
;   - Changing the position of individual plots on a page
;
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;***********************************************
begin
    lat0=37.40
    lon0=121.56
    wrfout_path="/home/lzhenn/array/lzhenn/WRFV3/run/wrfout_d03*"

    g_fig_name="../fig/Wind10m-home"
    g_font=0.012
    
    month_abbr = (/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                         "Oct","Nov","Dec"/)

	all_files = systemfunc ("ls "+wrfout_path)
    ctrl_in      = addfiles (all_files, "r")   ; note the "s" of addfile
	setfileoption("nc","SuppressClose",False) ; close too many files
	ListSetType (ctrl_in, "cat")             ; concatenate or "merge" (default)

	ctrl_var3  = wrf_user_getvar(ctrl_in,"rh", -1)  
    ctrl_var1  = wrf_user_getvar(ctrl_in,"ua", -1)  
	ctrl_var2  = wrf_user_getvar(ctrl_in,"va", -1)  
    

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
    ctrl_var2@lat2d = lat2d
    ctrl_var2@lon2d = lon2d
    point=getind_latlon2d(lat2d,lon2d,lat0,lon0)
    cor_x=point(0,0)
    cor_y=point(0,1)


;***********************************************
;  open a workstation and define colormap using rgb triplets
;***********************************************
  wks = gsn_open_wks("png","meteo") ; send graphics to PNG file
  colors = (/                                                        \
             (/255,255,255/),  \
             (/255,255,255/),   (/255,255,255/),   (/240,255,240/),  \
             (/220,255,220/),   (/190,255,190/),   (/120,255,120/),  \
             (/ 80,255, 80/),   (/ 50,200, 50/),   (/ 20,150, 20/) /) / 255.
;***********************************************
; Create a different resource list for each of the 5 plots
;***********************************************
  rh_res      = True
  temp_res    = True
  uv_res      = True
  rain_res    = True
  tempsfc_res = True
;***********************************************
; Here are the resources that rh_res, temp_res, and uv_res share.
;***********************************************
  rh_res@trYReverse   = True     ; Reverse the Y values.
  rh_res@gsnDraw      = False    ; Don't draw individual plot.
  rh_res@gsnFrame     = False    ; Don't advance frame.
  rh_res@vpXF         = 0.15     ; x location
  rh_res@vpYF         = 0.90     ; y location
  rh_res@vpWidthF     = 0.7      ; width
  rh_res@vpHeightF    = 0.40     ; height

  temp_res            = rh_res   ; copy shared resources to other lists
  uv_res              = rh_res
;***********************************************
; Relative humidity only resources
;***********************************************
  rh_res@cnFillOn          = True               ; turns on color fill
  rh_res@cnFillPalette     = colors             ; set color map
  rh_res@cnLineLabelsOn    = True               ; no contour labels
  rh_res@tiMainString      = "Meteogram for LGSA, 28/12Z" ; title

  rh_res@cnFillOn          = True               ; turns on the color
  rh_res@sfXArray          = taus               ; Define X/Y axes values that
  rh_res@sfYArray          = levels             ; all three data fields are on
  rh_res@tiYAxisString     = "Pressure (mb)"    ; Y axes label.

; y-left axis changes
  rh_res@tmYLMode       = "Explicit" ; Define own tick mark labels.
  rh_res@tmYLValues     = levels     ; location of explicit labels
  rh_res@tmYLLabels     = levels
  rh_res@tmYLMinorOn    = False            ; No Y-left minor tick marks.

; x-bottom axis changes
  rh_res@tmXBMode       = "Explicit" ; Define own tick mark labels.
  rh_res@tmXBValues     = taus       ; location of explicit labels
  rh_res@tmXBLabels     = (/"12z", "15z", "18z",  "21z", "Apr29", \
                            "03z", "06z", "09z",  "12z", "15z",   \
                            "18z", "21z", "Apr30","03z", "06z",   \
                            "09z", "12z", "15z",  "18z", "21z",   \
                            "May01", "03z", "06z",  "09z", "12z"/)

  rh_res@tmXBLabelAngleF      = 90.            ; change label angle
  rh_res@tmXBMinorOn          = False          ; No minor tick marks.
  rh_res@tmXBLabelJust        = "CenterCenter" ; label justification
  rh_res@tmXBLabelFontHeightF = .016           ; Font size
  rh_res@tiXAxisString        = ""             ; turn off x-axis string
;***********************************************
; Temperature only resources
;***********************************************
  temp_res@sfXArray        = taus    ; Define X/Y axes values that
  temp_res@sfYArray        = levels  ; all three data fields are on

  temp_res@cnLineLabelsOn  = True    ; no contour labels
  temp_res@cnLineThicknessF= 3.0     ; line thickness
  temp_res@cnLineColor     = "Red"   ; color of contour lines
;***********************************************
; wind barb only resources
;***********************************************
  uv_res@vfXArray            = taus       ; Define X/Y axes values that
  uv_res@vfYArray            = levels     ; all three data fields are on
  uv_res@vcRefAnnoOn         = False      ; turns off the ref vector
  uv_res@vcRefLengthF        = 0.040      ; set length of ref vector
  uv_res@vcGlyphStyle        = "WindBarb" ; turn on windbarbs
  uv_res@vcMonoWindBarbColor = True       ; to color the windbarbs with
                                          ; respect to speed use False
  uv_res@vcMapDirection = False			      ; needed to disassociate the coordinate plane from the wind barbs
  rhfill    = gsn_contour(wks,smothrh,rh_res)
  templine  = gsn_contour(wks,smothtemp,temp_res)
  windlayer = gsn_vector(wks,ugrid,vgrid,uv_res)
  rainhist  = gsn_csm_xy(wks,taus,rain03,rain_res)
  temptmsz  = gsn_csm_xy(wks,taus,tempht,tempsfc_res)
;********************************************************
; three of the above plots become one overlay plot
;********************************************************
  overlay(rhfill,templine)   ; result is templine over rhfill
  overlay(rhfill,windlayer)  ; result is windlayer over the other two
  draw(rhfill)               ; draw this overlay result
  frame(wks)                 ; finally advance the frame once all on page
end
