function adapt_thresh_prob, IMG, p_arr = p_arr, sign=sign

  ;+
  ; NAME: adapt_thresh_prob
  ;         
  ; PURPOSE: 
  ;     computes a set of percentile thresholds corresponding to a provided set of probabilities for a given data array
  ;     
  ; CALLING SEQUENCE: 
  ;     thresh_arr = adapt_thresh_prob(IMG, p_arr=, sign=)
  ;     
  ; INPUTS:
  ;     IMG:    data array for which the trhesholds are calculated
  ;     p_arr:  floating-point 1D array with percentile probabilities. Optional. 
  ;             Default value: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99]
  ;     sign:   a string flag defining whether the thresholds are computed for positive (sign='p'), 
  ;             negative (signe='n'), or both negative and positive (sign='np') elements of the IMG array. Optional.
  ;             Alllowed valued: 'p' (default), 'n', 'np' 
  ;             Default value: 'p'
  ;     
  ; OUTPUTS:
  ;     thresh_arr: a 1D array containing the computed threshold values 
  ;             
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ;     IMG = randomu(0, 100,100)-0.5
  ;     thresh_arr = adapt_thresh_prob(IMG, p_arr = [0.5, 0.7, 0.9], sign='n')
  ;     print, thresh_arr
  ;         0.247527    -0.350421    -0.452711
  ;
  ; MODIFICATION HISTORY:
  ;     V. Uritsky, 2024 - 
  ;-


  if n_elements(p_arr) eq 0 then p_arr = [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99]
  if n_elements(sign) eq 0 then sign = 'p'
  
  Nbins = 1E7  
  
  w_p = where(IMG gt 0)
  w_n = where(IMG lt 0)

  if w_p[0] ne -1 then begin
    h_p = histogram(IMG[w_p], nbins=nbins, loc = v_p)/float(n_elements(w_p)) 
    hc_p = total(h_p, /cumul)
    thresh_p_arr = v_p[value_locate(hc_p, p_arr)]
  endif else thresh_p_arr = fltarr(n_elements(p_arr))
   
  if w_n[0] ne -1 then begin
    h_n = histogram(abs(IMG[w_n]), nbins=nbins, loc = v_n)/float(n_elements(w_n))
    hc_n = total(h_n, /cumul)
    thresh_n_arr = -v_n[value_locate(hc_n, p_arr)]
  endif else thresh_n_arr = fltarr(n_elements(p_arr))

  
  ; forming 2D threshold array for compliance with process_corona.pro  
  ;thresh_arr = fltarr(2, 2*n_elements(p_arr))
  
  ;thresh_arr[1, 0:n_elements(p_arr)-1] = reverse(thresh_n_arr)
  ;thresh_arr[1, n_elements(p_arr):*] = thresh_p_arr
  ;thresh_arr[0, *] = min(img)
  
  if sign eq 'p' then thresh_arr=thresh_p_arr 
  if sign eq 'n' then thresh_arr=thresh_n_arr
  if sign eq 'np' then thresh_arr=[thresh_n_arr, thresh_p_arr]
  return, thresh_arr

End
