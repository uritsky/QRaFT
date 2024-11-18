
function blob_labeler, IMG_p, thresh, blob_stat=blob_stat, IMG_lbl=IMG_lbl, IMG_p_clr=IMG_p_clr  ;width_range=width_range, length_range=length_range, $ ;, lbl=lbl, h=h
                         
    
  ;+
  ; NAME:
  ;     blob_labeler
  ;
  ; PURPOSE:
  ;     Labels connected clusters in the input array IMG_p using a single detection threshold, 
  ;     computes geometric parameters of the cluster.
  ;     Executed by trace_blobs() with multiple combinations of cluster detection settings.
  ;
  ; CALLING SEQUENCE:
  ;     status = blob_labeler(IMG_p, thresh, width_range=width_range, length_range=length_range, blob_stat=blob_stat, IMG_lbl=IMG_lbl, IMG_p_clr=IMG_p_clr)
  ;
  ; INPUTS:
  ;
  ;     IMG_p         -     2D data array representing preprocessed input image in plane polar coordinates
  ;     thresh        -     detection threshold (lower bound for pixel intensity to be included in the clusters) 
  ;
  ; OUTPUTS:
  ;     status        -     integer-valued status flag equal 1 if at least one valid blob is found, and equal -1 otherwise. 
  ;     blob_stat     -     structure containing 1D arrays of geometric parameters of the detected blobs (features):
  ;         blob_stat.width   - feature width (size in the phi direction), in phi pixels
  ;         blob_stat.length  - feature length (size in the rho direction), in rho pixels
  ;         blob_stat.area    - feature area
  ;         blob_stat.rho_arr - 1D array of rho positions along the feature, ordered in the upward direction starting
  ;                             from the inner tracing boundary pres(rho_min_arr)
  ;         blob_stat.phi_arr - 1D array of phi values estimated at each rho_arr position
  ;         blob_stat.phi_fit - 1D array of interpolated phi values at each rho_arr position using a 2nd order polynomial fit
  ;         blob_stat.status  - the keyword returned by the IDL's poly_fit() function used for the polynomial fittiong  
  ;         
  ;     IMG_lbl       -       2D array of integer-valued cluster labels returned by the IDL's label_region() function for each image posision (phi, rho). 
  ;                           Has the same size as the input image IMG_p.        
  ;     IMG_p_clr -     array of real-valued cluster labels in the range 0 ... 256  (used for for quick color plotting). 
  ;     
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ;     status = blob_labeler(IMG_trimmed, thresh,  blob_stat=blob_stat, IMG_lbl=IMG_lbl)
  ;     (see trace_blobs() for more details)
  ;     
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-


  ;if n_elements(width_range) eq 0 then width_range=[2, 10]
  ;if n_elements(length_range) eq 0 then length_range=[10, 30];1E10]

  ; min_length = width_range[0]

  ; can add eccentricity

  IMG_lbl = long(label_region(IMG_p  gt thresh)) - 1

  blob_stat = blob_analyzer(IMG_lbl)

  if n_elements(blob_stat.length) gt 0 then status=1 else status = -1

  ;status = blob_validator(IMG_lbl, blob_stat, width_range, length_range, IMG_lbl_valid, blob_stat_valid)  
  
  ;if status eq 1 then begin ; valid blobs are found
    
  ;  IMG_lbl = IMG_lbl_valid & blob_stat = blob_stat_valid
    
    rnd = randomu(seed, max(IMG_lbl)+1)
    IMG_p_clr = IMG_p
    for i=0, max(IMG_lbl) do begin
      w = where(IMG_lbl eq i)
      IMG_p_clr[w] = rnd(i)*256
    endfor
    
  ;endif

  return, status

End

