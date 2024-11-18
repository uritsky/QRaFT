
function first_diff, y, phi_shift
  
  y_diff_1 = shift(y,-phi_shift) - shift(y, phi_shift)
  
  ;y_diff_1[0:phi_shift-1] = y_diff_1[phi_shift]
  
  for i=0, phi_shift-1 do y_diff_1[i] = y_diff_1[phi_shift]
   
  for i= n_elements(y)-phi_shift, n_elements(y)-1 do y_diff_1[i] = y_diff_1[n_elements(y)-phi_shift-1]
  
  return, y_diff_1
  
End

;---------------------------------------------------------------------------------

function second_diff,  y, phi_shift

  y_diff_2 = shift(y,-phi_shift) + shift(y, phi_shift) - 2*y

  
  for i=0, phi_shift-1 do y_diff_2[i] = y_diff_2[phi_shift]
  
  for i= n_elements(y)-phi_shift, n_elements(y)-1 do y_diff_2[i] = y_diff_2[n_elements(y)-phi_shift-1]
  
  ;y_diff_2[0:phi_shift-1] = y_diff_2[phi_shift]
  
  ;y_diff_2[-(phi_shift-1):-1] = y_diff_2[-phi_shift]

  return, y_diff_2

End
;---------------------------------------------------------------------------------

function gauss_sum, x, mu_arr, sd_arr, peak_arr

  y = fltarr(n_elements(x))
  
  for i=0, n_elements(mu_arr)-1 do begin
    y = y + peak_arr[i]*exp( -(x-mu_arr[i])^2/(2*sd_arr[i]^2) )
  endfor
  return, y
  
End
;---------------------------------------------------------------------------------

PRO qraft_fig_differencing, fig_dir=fig_dir

  if n_elements(fig_dir) eq 0 then fig_dir ="c:\Users\vadim\Documents\SCIENCE PROJECTS\N Arge\QRaFT paper\"
  
  fn_eps = "fig_differencing.eps"


  openps, fig_dir + fn_eps, 21, 30
  !P.noerase=1
  !P.charsize=0.7
  !P.thick=2
  pos = getpos(6, 2, region = [0.08, 0.1, 0.95, 0.90], xyspace=[0.055, 0.03])
  loadct,0, /silent
    
    setcolors
    N = 1000  
    phi_shift = 2 ; positions
    
    x = dindgen(N)/100.0
    y1 = gauss_sum(x, [5], [1.5], [1.01] )
         
    ;Np = 7
    ;;sd_arr = (randomu(s1, Np))*0.5+0.5
    ;peak_arr = (randomu(s1, Np))*0.5+0.5 ;abs(randomn(s1, Np))
    mu_arr = [1.5, 2.5, 3, 5, 6, 8, 9]        
    sd_arr = [0.51, 0.30, 0.50, 0.85, 0.51, 0.94, 0.83]
    peak_arr = [0.63, 0.24, 0.7, 1.96, 0.73, 0.5, 0.7]
    peak_arr = peak_arr/ max(peak_arr)  
    y2 = gauss_sum(x, mu_arr, sd_arr, peak_arr)
    
    y1_diff_1 = first_diff(y1, phi_shift)
    y1_diff_2 = second_diff(y1, phi_shift)
    y1_diff_2_abs = abs(y1_diff_2)
    w1=[] & for i=1, N-2 do if (y1_diff_2_abs[i] gt y1_diff_2_abs[i+1]) and (y1_diff_2_abs[i] gt y1_diff_2_abs[i-1]) then w1 = [w1,i]

    y2_diff_1 = first_diff(y2, phi_shift)
    y2_diff_2 = second_diff(y2, phi_shift)
    y2_diff_2_abs = abs(y2_diff_2)
    w2=[] & for i=1, N-2 do if (y2_diff_2_abs[i] gt y2_diff_2_abs[i+1]) and (y2_diff_2_abs[i] gt y2_diff_2_abs[i-1]) then w2 = [w2,i]
    
    img1 = fltarr(N, 100) & img2 = img1
    for i=0,99 do img1[*,i] = y1 
    for i=0,99 do img2[*,i] = y2
    
    xyouts, pos[0,0,0], 0.93,'Simple azimuthal structure', charsize=1.2, /normal
    xyouts, pos[0,1,0], 0.93,'Complex azimuthal structure', charsize=1.2, /normal
     
    plot, x, y1,  ytitle ='Intensity (arb. units)', title='Intensity profile', pos=pos[0,0,*]
    letterlabel1, '(a)', 1.2 
    for i=0,n_elements(w1)-1 do plots, x[w1[i]]*[1,1], !Y.crange, color=2, lines=2
    
    plot, x, y1_diff_1, ytitle ='Intensity (arb. units)', title='1st order difference', pos=pos[1,0,*]
    letterlabel1, '(b)', 1.2
    for i=0,n_elements(w1)-1 do plots, x[w1[i]]*[1,1], !Y.crange, color=2, lines=2

    plot, x, y1_diff_2, ytitle ='Intensity (arb. units)', title='2nd order difference', $
      yrange=1.01*[min([y1_diff_2, abs(y1_diff_2)]), max([y1_diff_2, abs(y1_diff_2)])],  pos=pos[2,0,*]
    oplot, x, y1_diff_2_abs, color=2
    oplot, x[w1], y1_diff_2_abs[w1], psym=4, thick=3     
    letterlabel1, '(c)', 1.2
    for i=0,n_elements(w1)-1 do plots, x[w1[i]]*[1,1], !Y.crange, color=2, lines=2
    
    image_plot_1, img1, x, findgen(100), ct=0, xtitle=greek('phi')+' (degrees)', ytitle=greek('rho')+' (pixels)', $
      plottitle='Simulated image', colorbar_place=0, pos=pos[3,0,*]
    setcolors
    letterlabel1, '(d)', 1.2, color=1 
    for i=0,n_elements(w1)-1 do plots, x[w1[i]]*[1,1], !Y.crange, color=2, lines=2, thick=4

    ; ===
     
    plot, x, y2,  title='Intensity profile', pos=pos[0,1,*]
    letterlabel1, '(e)', 1.2
    for i=0,n_elements(w2)-1 do plots, x[w2[i]]*[1,1], !Y.crange, color=2, lines=2

    plot, x, y2_diff_1, title='1st order difference', pos=pos[1,1,*]
    letterlabel1, '(f)', 1.2
    for i=0,n_elements(w2)-1 do plots, x[w2[i]]*[1,1], !Y.crange, color=2, lines=2

    plot, x, y2_diff_2,  title='2nd order difference', $
      yrange=1.01*[min([y2_diff_2, abs(y2_diff_2)]), max([y2_diff_2, abs(y2_diff_2)])],  pos=pos[2,1,*]
    oplot, x, y2_diff_2_abs, color=2
    oplot, x[w2], y2_diff_2_abs[w2], psym=4, thick=3
    letterlabel1, '(g)', 1.2
    for i=0,n_elements(w2)-1 do plots, x[w2[i]]*[1,1], !Y.crange, color=2, lines=2

    image_plot_1, img2, x, findgen(100), ct=0, xtitle=greek('phi')+' (degrees)',  $
      plottitle='Simulated image', colorbar_place=0, pos=pos[3,1,*]
    setcolors
    letterlabel1, '(h)', 1.2, color=1    
    for i=0,n_elements(w2)-1 do plots, x[w2[i]]*[1,1], !Y.crange, color=2, lines=2, thick=4

  closeps
  !P.noerase=0


End