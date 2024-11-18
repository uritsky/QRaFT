
function blob_analyzer, IMG_lbl, min_length=min_length, poly_order=poly_order

  ;+
  ; NAME:
  ;     blob_analyzer
  ;
  ; PURPOSE:
  ;     Computes geometric parameters of labeled image clusters.
  ;     Called by blob_labeler(). 
  ;
  ; CALLING SEQUENCE:
  ;     blob_stat = blob_analyzer(IMG_lbl)
  ;
  ; INPUTS:
  ;     IMG_lbl     -   2D array of cluster labels returned by blob_labeler()
  ;     min_length  -   minimum radial length of the clusters which undergo polynomial interpolation, in pixel units. 
  ;                     Optional, default value 5
  ;     poly_order  -   the order of the phi(rho) polynomials used to interpolate the clusters.
  ;                     Optional, default value 2 (quatratic polynomials)) 
  ;
  ; OUTPUTS:
  ;     blob_stat     - a structure containing 1D arrays of geometric parameters of the detected blobs (features):
  ;         blob_stat.width   - feature width (size in the phi direction), in phi pixels
  ;         blob_stat.length  - feature length (size in the rho direction), in rho pixels
  ;         blob_stat.area    - feature area
  ;         blob_stat.rho_arr - 1D array of rho positions along the feature, ordered in the upward direction starting
  ;                             from the inner tracing boundary pres(rho_min_arr)
  ;         blob_stat.phi_arr - 1D array of phi values estimated at each rho_arr position
  ;         blob_stat.phi_fit - 1D array of interpolated phi values at each rho_arr position using a 2nd order polynomial fit
  ;         blob_stat.status  - the keyword returned by the IDL's poly_fit() function used for the polynomial fittiong       
  ;
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ;     blob_stat = blob_analyzer(IMG_lbl)
  ;     (see blob_labeler() for more details)
  ;
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-


  if n_elements(min_length) eq 0 then min_length = 5
  if n_elements(poly_order) eq 0 then poly_order = 2;3


  phi_2D = fix(IMG_lbl) & phi_2D[*]=0 & rho_2D = phi_2D
  mask = phi_2D
  for i = 0, n_elements(phi_2D[*,0])-1 do phi_2D[i,*] = i
  for k = 0, n_elements(rho_2D[0,*])-1 do rho_2D[*,k] = k

  n_blobs = max(IMG_lbl)+1 ; counting 0th blob
  n_rho = n_elements(IMG_lbl[0,*])

  width = fltarr(n_blobs)
  length = fltarr(n_blobs)
  area = fltarr(n_blobs)

  phi_arr = fltarr(n_blobs, n_rho)
  phi_fit_arr = fltarr(n_blobs, n_rho)
  rho_arr = fltarr(n_blobs, n_rho)
  status_arr = intarr(n_blobs)

  for i=0, n_blobs-1 do begin
    w = where(IMG_lbl eq i)
    mask[*] = 0 & mask[w] = 1

    width[i] = max(total(mask, 1))
    length[i] = max(rho_2D[w]) - min(rho_2D[w]) + 1
    area[i] = n_elements(w)

    if length[i] ge min_length then begin
      n = total(mask, 1) & xsum = total(phi_2D*mask, 1) & ww = where(n gt 0)
      phi = xsum[ww]/n[ww]
      rho = min(rho_2D[w]) + findgen(length[i])

      fit = poly_fit(rho, phi, poly_order, status=status)
      phi_fit = fltarr(n_elements(phi)) & for k=0, poly_order do phi_fit = phi_fit + fit[k]*(rho^k)

      phi_arr[i,0:length[i]-1] = phi
      phi_fit_arr[i,0:length[i]-1] = phi_fit
      rho_arr[i,0:length[i]-1] = rho
      status_arr[i] = status

      ; Visualize each blob:
      ;
      ;erase & plot, rho_2D[w], phi_2D[w], psym=4, xrange = minmax(rho_2D[w])+ [-10,10], $
      ;  yrange = minmax(phi_2D[w])+ [-20,20], xtitle='rho', ytitle='phi'
      ;oplot, rho, phi, thick=1
      ;oplot, rho, phi_fit, thick=3
      ;stop

    endif

  endfor

  blob_stat = {width:width, length:length, area:area, phi:phi_arr, phi_fit:phi_fit_arr, rho:rho_arr, $
    status:status_arr}

  return, blob_stat

End