
pro qraft_fig_tracing, qres, suffix, title=title, fig_dir=fig_dir
  if n_elements(title) eq 0 then title=''
  if n_elements(suffix) eq 0 then suffix = ''
  if n_elements(fig_dir) eq 0 then fig_dir ="c:\Users\vadim\Documents\SCIENCE PROJECTS\N Arge\QRaFT paper\" 
  if n_elements(title) eq 0 then title=suffix
  
  fn_eps = 'fig_tracing_'+suffix+'.eps'
  
  openps, fig_dir + fn_eps, 21, 30
  !P.noerase=1
  !P.charsize=1.0
  !P.thick=5
  pos = getpos(4, 1, region = [0.08, 0.1, 0.95, 0.90], xyspace=[0.055, 0.03])
  loadct,0, /silent
  
  Rs_arcsec = 959.63 
  
    image_plot_1, qres.IMG_d2_phi_enh, qres.Phi, qres.Rho/Rs_arcsec, colorbar_place=0, pos=pos[0,0,*], $
      range=[0, adapt_thresh_prob(qres.IMG_d2_phi_enh, p=0.95)], xtitle=greek('phi')+ ' (radians)', ytitle=greek('rho')+' (R!DS!N)', $
      plottitle=title

    ;setcolors
    loadct, 34, /silent
    for i=0, n_elements(qres.rho_min_arr)-1 do $
      for k = 0, n_elements(qres.p_arr)-1 do begin
      i1=qres.blob_indices[0,k,i] & i2=qres.blob_indices[1,k,i]
      ;plots, qres.blob_stat.phi_fit[i1:i2,*], qres.blob_stat.rho[i1:i2,*], psym=4, color=2
      for j=i1, i2 do begin
        N = qres.blob_stat.length[j]
        phi_ = qres.c.d_phi*qres.blob_stat.phi_fit[j,0:N-1]
        
        rho_ = qres.c.pix_size*(qres.c.d_rho*qres.blob_stat.rho[j,0:N-1] + qres.c.rho_min) / Rs_arcsec
        
        
        ;rho_ = qres.rho[0:N-1]/Rs_arcsec
        ;plots, phi_, rho_, psym=1, color=2
        ;plots, phi_, rho_, color=randomu(seed)*255
        
        clr = 256*(n_elements(qres.rho_min_arr) - i )/n_elements(qres.rho_min_arr) ;reversed order: i=0 -> red
        
        plots, phi_, rho_, color = clr
      
      endfor
      
    endfor
    
  closeps
  !P.noerase=0

End