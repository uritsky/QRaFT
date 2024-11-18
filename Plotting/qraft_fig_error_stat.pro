
pro qraft_fig_error_stat, qres, B1, B2, suffix, title=title, fig_dir=fig_dir
  
  if n_elements(title) eq 0 then title=''
  if n_elements(suffix) eq 0 then suffix = ''
  if n_elements(fig_dir) eq 0 then fig_dir ="c:\Users\vadim\Documents\SCIENCE PROJECTS\N Arge\QRaFT paper\"
  if n_elements(title) eq 0 then title=suffix

  fn_eps = 'fig_B_error_stat_'+suffix+'.eps'

  openps, fig_dir + fn_eps, 20, 20
  !P.noerase=1
  !P.charsize=0.7
  !P.thick=2
  pos = getpos(3, 3, region = [0.05, 0.1, 0.95, 0.90], xyspace=[0.07, 0.03])

  img_err = angles_vs_B(qres.IMG_ANGLES, qres.IMG_ANGLES_N, B1, B2, qres.c.XYCenter)
  X = findgen(n_elements(img_err[*,0]))- qres.c.XYCenter[0]
  Y = findgen(n_elements(img_err[0,*]))- qres.c.XYCenter[1]

  loadct, 0, /silent
  setcolors

  w = where(qres.img_angles_n gt 0)
  hy = histogram(img_err[w], binsize=0.01, loc=hx) & hx = hx*180/!Pi
  hy_abs = histogram(abs(img_err[w]), binsize=0.01, loc=hx_abs) & hx_abs = hx_abs*180/!Pi 
  hy_abs_cum = 100*total(hy_abs, /cum)/float(n_elements(w))
  
  plot, hx, hy, pos=pos[0,0,*], xrange=[-45,45], title='Signed', xtitle= greek('theta')+'!DB!N [degrees]', ytitle= 'Number of occurrences'
  s_mu = greek('mu')+' = ' + string(mean(img_err[w]*180/!Pi), format='(F4.1)' )+' !Uo!N'
  s_m =  'm = '            + string(median(img_err[w]*180/!Pi), format='(F4.1)' )+' !Uo!N'
  s_sd = greek('sigma') +' = ' + string(stddev(img_err[w]*180/!Pi), format='(F4.1)' )+' !Uo!N'
  
  xyouts, !x.window[1] - 0.08, !y.window[1]-0.030, s_mu, /normal
  xyouts, !x.window[1] - 0.08, !y.window[1]-0.048, s_m, /normal
  xyouts, !x.window[1] - 0.08, !y.window[1]-0.066, s_sd, /normal  
  LetterLabel2, '(a)', size=1.0, xyshift=[-0.01, 0.01]
  
   
  plot, hx_abs, hy_abs, pos=pos[0,1,*], title='Unsigned', xrange=[0,45], xtitle= '| '+greek('theta')+'!DB!N | [degrees]', ytitle= 'Number of occurrences'
  s_mu = greek('mu')+' = ' + string(mean(abs(img_err[w]*180/!Pi)), format='(F4.1)' )+' !Uo!N'
  s_m =  'm = '            + string(median(abs(img_err[w]*180/!Pi)), format='(F4.1)' )+' !Uo!N'
  s_sd = greek('sigma') +' = ' + string(stddev(abs(img_err[w]*180/!Pi)), format='(F4.1)' )+' !Uo!N'

  xyouts, !x.window[1] - 0.08, !y.window[1]-0.030, s_mu, /normal
  xyouts, !x.window[1] - 0.08, !y.window[1]-0.048, s_m, /normal
  xyouts, !x.window[1] - 0.08, !y.window[1]-0.066, s_sd, /normal
  LetterLabel2, '(b)', size=1.0, xyshift=[-0.01, 0.01]
  
  str_fill = strjoin(strarr(20-strlen(suffix))+' ')
  print, suffix + str_fill + string(mean(abs(img_err[w]*180/!Pi)), format='(F4.1)' ), string(median(abs(img_err[w]*180/!Pi)), format='(F4.1)' )

  plot, hx_abs, hy_abs_cum, pos=pos[0,2,*], xrange=[0,45], $
    title='Cummulative unsigned', xtitle= '| '+greek('theta')+'!DB!N | [degrees]', ytitle= 'Cummilative occurrence rate, %'    

  i_5 = max(where(hx_abs le 5))
  i_10 = max(where(hx_abs le 10))
  i_15 = max(where(hx_abs le 15))
  
  P_5 = 'P(5!Uo!N) =  ' + string(  hy_abs_cum[i_5], format='(F5.1)' )+'%'
  P_10 = 'P(10!Uo!N) = ' + string(  hy_abs_cum[i_10], format='(F5.1)' )+'%'
  P_15 = 'P(15!Uo!N) = ' + string(  hy_abs_cum[i_15], format='(F5.1)' )+'%'

  xyouts, !x.window[1] - 0.12, !y.window[1]-0.030, p_5, color=4, /normal
  xyouts, !x.window[1] - 0.12, !y.window[1]-0.048, p_10, color=2,  /normal
  xyouts, !x.window[1] - 0.12, !y.window[1]-0.066, p_15, color=7, /normal

  oplot, hx_abs[i_5]*[1,1], hy_abs_cum[i_5]*[0,1], color=4
  oplot, hx_abs[i_5]*[0,1], hy_abs_cum[i_5]*[1,1], color=4

  oplot, hx_abs[i_10]*[1,1], hy_abs_cum[i_10]*[0,1], color=2
  oplot, hx_abs[i_10]*[0,1], hy_abs_cum[i_10]*[1,1], color=2

  oplot, hx_abs[i_15]*[1,1], hy_abs_cum[i_15]*[0,1], color=7
  oplot, hx_abs[i_15]*[0,1], hy_abs_cum[i_15]*[1,1], color=7
  
  LetterLabel2, '(c)', size=1.0, xyshift=[-0.01, 0.01]


  !P.multi=0

  closeps
  !P.noerase=0

End