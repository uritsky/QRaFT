
function azimuthal_diff, IMG_p, phi_shift, smooth_phi_rho 

  ;+
  ; NAME:
  ;     azimuthal_diff
  ;
  ; PURPOSE:
  ;     Returned azimuthally differenced and smoothed data array in plane polar coordunates 
  ;
  ; CALLING SEQUENCE:
  ;     IMG_d2_phi = azimuthal_diff(IMG_p, phi_shift, smooth_phi_rho)
  ;
  ; INPUTS:
  ;     IMG_p           - 2D data array in plane polar coordunates, to be processed with this method
  ;     phi_shift       - 1/2 of the phi step used for computing central azimuthal differences
  ;     smooth_phi_rho  - 2-element array with phi and rho sizes of the anisotropic smoothing window applied 
  ;                       to the differenced array. 
  ;                       smooth_phi_rho = [phi_sindow_size, rho_sindow_size] 
  ; OUTPUTS:
  ;     IMG_d2_phi      - 2D data array of the same stgructure as IMG_p containing the computed central alimuthal differences
  ;                       at each location
  ;
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ;     ; imitate polar image with radially aligned structure:
  ;     IMG_p = randomu(0, 360,200) & IMG_p = smooth(IMG_p, [3, 100], /edge_tr) 
  ;     IMG_d2_phi = azimuthal_diff(IMG_p, 3, [6,2])
  ;     tvscl, IMG_d2_phi
  ;     
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-


  ; One-step unsigned 2nd order azimuthal difference in polar coordinates and smoothing:
  
  IMG_d2_phi = shift(IMG_p, [phi_shift,0]) + shift(IMG_p, [-phi_shift,0]) - 2*IMG_p
  
  IMG_d2_phi = smooth(IMG_d2_phi,  smooth_phi_rho)

  return, IMG_d2_phi
  
End