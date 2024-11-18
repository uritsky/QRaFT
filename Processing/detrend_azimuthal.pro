
function detrend_azimuthal, IMG_p, phi_detr
  
  ;+
  ; NAME:
  ;     detrend_azimuthal
  ;
  ; PURPOSE:
  ;     Detrends polar image in azimuthal direction using periodic boundary conditions in the phi direction
  ;
  ; CALLING SEQUENCE:
  ;     IMG_p_detr = detrend_azimuthal(IMG_p, phi_detr)
  ; 
  ; INPUTS:
  ;     IMG_p       - 2D array with an enhanced solar image in plane polar coordnates
  ;     phi_detr    - length of the azimuthal sliding window used for detrending, in phi pixel units
  ;
  ; OUTPUTS:
  ;     IMG_p_detr  - azimuthally detrended verion of IMG_p
  ;
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ;     IMG_p_detr = detrend_azimuthal(IMG_p, 5)
  ;     
  ;
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-
   
  sz = size(IMG_p, /dim) & Np=sz[0] & Nr = sz[1]
  phi_profile = mean(IMG_p, dim=2) ;rho-averaged azimuthhal trend (1D)
  IMG_p_smooth = fltarr(Np, Nr)
  for i=0, Np-1 do IMG_p_smooth[i,*] = phi_profile[i] ; 2D array filled with the average azim. trend
  IMG_p_smooth = smooth_polar(IMG_p_smooth, [phi_detr,1])
  IMG_p_detr = IMG_p / IMG_p_smooth
  
  return, IMG_p_detr
  
End