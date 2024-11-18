
pro qraft_fig_B_alignment, qres, B1, B2, suffix, title=title, fig_dir=fig_dir


  if n_elements(title) eq 0 then title=''
  if n_elements(suffix) eq 0 then suffix = ''
  if n_elements(fig_dir) eq 0 then fig_dir ="c:\Users\vadim\Documents\SCIENCE PROJECTS\N Arge\QRaFT paper\"
  if n_elements(title) eq 0 then title=suffix

  fn_eps = 'fig_B_alignment_'+suffix+'.eps'
  
  openps, fig_dir + fn_eps, 20, 20
  !P.noerase=1
  !P.charsize=0.7
  !P.thick=5
  pos = getpos(1, 1, region = [0.08, 0.1, 0.95, 0.90], xyspace=[0.055, 0.03])
  loadct,0, /silent
  
  setcolors
  ;plot_B_lines, B1, B2, XYCenter=qres.c.XYCenter, rho_min=qres.c.rho_range[0], title=title, pos=pos[0,0,*]
  plot_B_lines, B1, B2, XYCenter=qres.c.XYCenter, pos=pos[0,0,*], /velo, $
    title=title, xtitle='X [pixels]', ytitle='Y [pixels]'  
  
  setcolors
  for i=0, n_elements(qres.features)-1 do begin
    N=qres.features[i].n_nodes
    xx = qres.features[i].xx_r[0:N-1] - qres.c.XYCenter[0]
    yy = qres.features[i].yy_r[0:N-1] - qres.c.XYCenter[1]
    plots, xx, yy, color=2, thick=2        
  endfor

  R_min=qres.c.rho_min
  rx = R_min*cos(findgen(360)*!Pi/180 )
  ry = R_min*sin(findgen(360)*!Pi/180)
  plots, rx, ry, lines=2
  
  plots, [0], [0], psym=4, thick=2

  closeps
  !P.noerase=0

End