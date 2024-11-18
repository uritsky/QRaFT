
function trace_blobs, IMG, p_arr, rho_min_arr, IMG_lbl_arr=IMG_lbl_arr, blob_indices=blob_indices

  ;+
  ; NAME:
  ;     trace_blobs
  ;
  ; PURPOSE:
  ;     Returns geometric characteristics of detected blobs in plane polar coordinates based on multiple combinations 
  ;     of tracing parameters (minimum radial distances and percentile detection thresholds)
  ;
  ; CALLING SEQUENCE:
  ;     blob_stat = trace_blobs(IMG, p_arr, rho_min_arr, IMG_lbl_arr=IMG_lbl_arr, blob_indices=blob_indices)
  ;
  ; INPUTS:
  ;     IMG           - 2D array with an enhanced solar image in plane polar coordnates
  ;     p_arr         - 1D array containing probability values used to compute percentile thresholds
  ;     rho_min_arr   - 1D array containing array indices defining the position of the lower coronal boundary (in rho pixel inits)
  ;                   used for feature tracing. The coronal region below this boundary is masked out. 
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
  ;     IMG_lbl_arr   -       4D array of pixel labels returned by the IDL's label_region() function at each image posision (phi, rho) and for each 
  ;                           combination of p_arr[k] and rho_min_arr[i], making it possible to analyze the results of different tracing runs
  ;                           separately from each other at a later stage. The order of the array direcitons: IMG_lbl_arr[phi,rho,k,i].       
  ;     blob_indices  -       3D array containing first and last label values of the pixel blobs (features) identified using each
  ;                           combination of p_arr[k] and rho_min_arr[i]. The order of the array direcitons: blob_indices[[blob_ind_1, blob_ind_2],k,i].  
  ;     
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ;     blob_stat = trace_blobs(IMG_d2_phi_enh, p_arr, rho_min_arr, IMG_lbl_arr=IMG_lbl_arr, blob_indices=blob_indices) 
  ;     (see QRaFT.pro for more details)
  ;      
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-
  
  sz = size(IMG,/dim)

  IMG_lbl_arr = fltarr(sz[0], sz[1], n_elements(p_arr), n_elements(rho_min_arr))
  blob_indices = intarr(2,n_elements(p_arr), n_elements(rho_min_arr))
  IMG_trimmed = IMG

  blob_ind_1 = 0

  for i=0, n_elements(rho_min_arr)-1 do begin
    IMG_trimmed[*, 0:rho_min_arr[i]] = 0

    for k = 0, n_elements(p_arr)-1 do begin

      status = blob_labeler(IMG_trimmed, adapt_thresh_prob(IMG_trimmed, p=p_arr[k]), $lbl=lbl, h=h, $
        blob_stat=blob_stat, IMG_lbl=IMG_lbl)

      IMG_relbl = IMG_lbl
      w = where(IMG_lbl ne -1)
      IMG_relbl[w] = IMG_relbl[w] + blob_ind_1
      IMG_lbl_arr[*,*,k,i] = IMG_relbl

      blob_stat_merged = blob_stat_merger(blob_stat_merged, blob_stat)

      blob_ind_2 = blob_ind_1 + n_elements(blob_stat.area) - 1
      blob_indices[*,k,i] = [blob_ind_1, blob_ind_2]
      blob_ind_1 = blob_ind_2 + 1

    endfor

  endfor

  ; window, 0, xsize=3000, ysize=1200
  ; loadct, 0 & erase
  ; image_plot_1, IMG, range=[0, adapt_thresh_prob(IMG, p=0.95)]
  ; setcolors
  ; for i=0, n_elements(rho_min_arr)-1 do $
  ;   for k = 0, n_elements(p_arr)-1 do begin
  ;     i1=blob_indices[0,k,i] & i2=blob_indices[1,k,i]
  ;     plots, blob_stat_merged.phi_fit[i1:i2,*], blob_stat_merged.rho[i1:i2,*], psym=4, color=2
  ;   endfor
  ; stop

  return, blob_stat_merged ;IMG_lbl_arr

End
