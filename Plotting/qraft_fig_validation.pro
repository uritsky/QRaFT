
pro qraft_fig_validation, qres, suffix, title=title, fig_dir=fig_dir
  if n_elements(title) eq 0 then title=''
  if n_elements(suffix) eq 0 then suffix = ''
  if n_elements(fig_dir) eq 0 then fig_dir ="c:\Users\vadim\Documents\SCIENCE PROJECTS\N Arge\QRaFT paper\"
  if n_elements(title) eq 0 then title=suffix

  fn_eps = 'fig_validation_'+suffix+'.eps'
  
  openps, fig_dir + fn_eps, 20, 21
  !P.noerase=1
  !P.charsize=0.7
  !P.thick=5
  pos = getpos(1, 1, region = [0.08, 0.1, 0.95, 0.90], xyspace=[0.055, 0.03])
  loadct,0, /silent
  
  Rs_arcsec = 959.63 

  image_plot_1, qres.IMG_orig, qres.X, qres.Y, colorbar_place=0, pos=pos[0,0,*], ct=0, $
    range=[-0.5, 1]*adapt_thresh_prob(qres.IMG_orig, p=0.95), plottitle=title, $
    xtitle='X [arcsec]', ytitle='Y [arcsec]'

;  image_plot_1, qres.IMG_orig, qres.X, qres.Y, colorbar_place=0, pos=pos[0,0,*], ct=0, $
;    range=adapt_thresh_prob(qres.IMG_orig, p=[0.1,0.95]), plottitle=title, $
;    xtitle='X [arcsec]', ytitle='Y [arcsec]'
    
    setcolors
    
    for i=0, n_elements(qres.blob_stat.length)-1 do begin
      l=qres.blob_stat.length[i]
      phi= qres.c.d_phi*qres.blob_stat.phi_fit[i,0:l-1]
      rho= qres.c.pix_size*(qres.c.d_rho*qres.blob_stat.rho[i,0:l-1] + qres.c.rho_min)
      xx_r = rho*cos(phi) &  yy_r = rho*sin(phi)
      plots, [xx_r, yy_r], color=4, thick=2
    endfor
    
    for i=0, n_elements(qres.features)-1 do begin
      n=qres.features[i].n_nodes
      xx_r = qres.c.pix_size*(qres.features[i].xx_r[0:n-1]-qres.c.XYCenter[0]) 
      yy_r = qres.c.pix_size*(qres.features[i].yy_r[0:n-1]-qres.c.XYCenter[1])
      plots, xx_r, yy_r, color=2, thick=2
    endfor    
  closeps
  !P.noerase=0

End