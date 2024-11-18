
pro qraft_fig_B_errors, qres, B1, B2, suffix, title=title, fig_dir=fig_dir
  
  if n_elements(title) eq 0 then title=''
  if n_elements(suffix) eq 0 then suffix = ''
  if n_elements(fig_dir) eq 0 then fig_dir ="c:\Users\vadim\Documents\SCIENCE PROJECTS\N Arge\QRaFT paper\"
  if n_elements(title) eq 0 then title=suffix

  fn_eps = 'fig_B_errors_'+suffix+'.eps'
      
  openps, fig_dir + fn_eps, 20, 20
  !P.noerase=1
  !P.charsize=0.7
  !P.thick=1
  pos = getpos(1, 1, region = [0.08, 0.1, 0.90, 0.90], xyspace=[0.055, 0.03])
  
  img_err = angles_vs_B(qres.IMG_ANGLES, qres.IMG_ANGLES_N, B1, B2, qres.c.XYCenter) 
  w = where(img_err eq 0)
  ;if w[0] ne-1 then img_err[w] = !values.f_nan
  
  X = findgen(n_elements(img_err[*,0]))- qres.c.XYCenter[0]
  Y = findgen(n_elements(img_err[0,*]))- qres.c.XYCenter[1]

  loadct, 17, /silent
  TVLCT, [0], [0], [0]
  image_plot_1, patch_image_holes(img_err),  X, Y, range=[-0.1, 0.1], pos=pos[0,0,*], $
    plottitle=title, xtitle= 'X [pixels]', ytitle='Y [pixels]'
  
  setcolors

  plot_B_lines, B1, B2, XYCenter=qres.c.XYCenter, pos=pos[0,0,*], $
    title=title, xtitle='X [pixels]', ytitle='Y [pixels]', /over, line_color=0    

  R_min=qres.c.rho_min
  rx = R_min*cos(findgen(360)*!Pi/180)
  ry = R_min*sin(findgen(360)*!Pi/180)
  plots, rx, ry, lines=2
  
  plots, [0], [0], psym=4, thick=2

  closeps
  !P.noerase=0

End