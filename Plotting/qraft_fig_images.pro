
PRO qraft_fig_images, qres, suffix, title=title, fig_dir=fig_dir 

  if n_elements(suffix) eq 0 then suffix = ''
  if n_elements(fig_dir) eq 0 then fig_dir ="c:\Users\vadim\Documents\SCIENCE PROJECTS\N Arge\QRaFT paper\"
  if n_elements(title) eq 0 then title= ''
  
  fn_eps = 'fig_images_'+suffix+'.eps'  

  openps, fig_dir + fn_eps, 21, 26
  !P.noerase=1
  !P.charsize=1.0
  !P.thick=2
  pos = getpos(2, 2, region = [0.08, 0.1, 0.90, 0.90], xyspace=[0.06, 0.12])
  loadct,0, /silent
  
  ;datetime_str = header_value(qres.header, 'DATE-OBS')
  ;datetime_str = strmid(datetime_str, 1, 19)
   
  Rs_arcsec = 959.63 
  xyouts, pos[0,0,0]+0.3, pos[0,0,3]+0.04, title, charsize=1.4, /normal
  
  
    image_plot_1, qres.IMG_orig, qres.X, qres.Y, colorbar_place=3, pos=pos[0,0,*], ct=0, $
      range=[-0.5, 1]*adapt_thresh_prob(qres.IMG_orig, p=0.95), plottitle='Rectangular coordinates', $
      xtitle='X [arcsec]', ytitle='Y [arcsec]'
      ;range=[0, adapt_thresh_prob(qres.IMG_orig, p=0.95)]
      setcolors
      letterlabel1, '(a)', 1.2, color=1

    image_plot_1, qres.IMG_orig_p, qres.Phi, qres.Rho/Rs_arcsec, colorbar_place=3, pos=pos[1,0,*], ct=0, $
      range=[-0.5,1]* adapt_thresh_prob(qres.IMG_orig_p, p=0.95), plottitle='Polar coordinates)', $
      xtitle=greek('phi')+' [radians]', ytitle=greek('rho')+' [R!DS!N]'
      setcolors
      letterlabel1, '(b)', 1.2, color=1
      
    image_plot_1, qres.IMG_d2_phi, qres.Phi, qres.Rho/Rs_arcsec, colorbar_place=3, pos=pos[0,1,*], ct=0, $
      range=adapt_thresh_prob(qres.IMG_d2_phi, p_arr=0.95, sign='np'), plottitle = '2nd order difference', $
      xtitle=greek('phi')+ ' [radians]', ytitle=greek('rho')+' [R!DS!N]'
      ;range=adapt_thresh_prob(qres.IMG_d2_phi_, p_arr=0.99, sign='np')
      setcolors
      letterlabel1, '(c)', 1.2, color=1

    image_plot_1, qres.IMG_d2_phi_enh, qres.Phi, qres.Rho/Rs_arcsec, colorbar_place=3, pos=pos[1,1,*], ct=0, $
      range = [0, adapt_thresh_prob(qres.IMG_d2_phi_enh, p=0.95)], plottitle = '2nd order difference, enhanced', $
      xtitle=greek('phi')+ ' [radians]', ytitle=greek('rho') + ' [R!DS!N]'
      setcolors
      letterlabel1, '(d)', 1.2, color=1
    
  closeps
  !P.noerase=0

End  