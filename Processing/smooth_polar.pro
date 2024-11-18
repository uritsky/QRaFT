
function smooth_polar, IMG, smooth_xy

  ;+
  ; NAME:
  ;     smooth_polar
  ;
  ; PURPOSE:
  ;     Smoothens image in polar coordinates using periodic boundary conditions in the azimuthal (phi) direction
  ;
  ; CALLING SEQUENCE:
  ; 
  ;     IMG_smooth = smooth_polar(IMG, smooth_xy)
  ;
  ; INPUTS:
  ;     IMG         - image in polar coordinates (phi, rho) 
  ;     smooth_xy   - 2-element array [win_phi, win_rho] containing the sizes of the smoothing window 
  ;                 in the phi and rho directions, used by IDL smooth() funciton 
  ;
  ; OUTPUTS:
  ;     IMG_smooth  - processed image
  ;
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ;     IMG_p_smooth = smooth_polar(IMG_p, [3, 15])
  ;
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-


  ; x = azimuthal direction, cyclic
  ; y = radial direction
  
  img_ = smooth(img, [1, smooth_xy[1]], /edge_trunc)
  
  for y=0, n_elements(img[0,*])-1 do $
        img_[*,y] = smooth(img_[*,y], smooth_xy[0], /edge_wrap)  
    
  
  return, img_
  
End