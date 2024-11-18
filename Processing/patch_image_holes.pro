
function patch_image_holes, IMG, hole_flag=hole_flag ;, count=count

  ;+
  ; NAME:
  ;     patch_image_holes
  ;
  ; PURPOSE:
  ;     Patches small (1-3) isolated groups of empty or invalid pixels using nearest-neighbor interpolation
  ;
  ; CALLING SEQUENCE:
  ;     IMG_fixed = patch_image_holes(IMG, hole_flag=hole_flag)
  ;
  ; INPUTS:
  ;     IMG         - corrupted image containing invalid pixels
  ;     hole_flag   - numerical value used to identify invalid pixels.
  ;                   Optional, default value 0.0
  ;
  ; OUTPUTS:
  ;     IMG_fixed   - restored image, same size as IMG. Invalid pixels are filled with 
  ;                   the average over the valid nearest neighbors (1 to 4). Diagonal neighbors not included. 

  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ;   IMG_orig_p = patch_image_holes(IMG_orig_p)
  ;
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-

  
  ;count = 0LL
  
  if n_elements(hole_flag) eq 0 then hole_flag=0.0
  
  w_holes = where(IMG eq hole_flag)
  
  if w_holes[0] ne -1 then begin
    ind = array_indices(IMG, w_holes)
    Nx = n_elements(IMG[*,0]) & Ny = n_elements(IMG[0,*])
    
    w = where(ind[0,*] gt 0) & ind = ind[*,w]
    w = where(ind[1,*] gt 0) & ind = ind[*,w]
    w = where(ind[0,*] lt (Nx-1)) & ind = ind[*,w]
    w = where(ind[1,*] lt (Ny-1)) & ind = ind[*,w]
    
    IMG_ = IMG
    for i=0, n_elements(w)-1 do begin
      xL = max([ ind[0,i]-1,  0   ])
      xR = min([ ind[0,i]+1, Nx-1 ])
      yB = max([ ind[1,i]-1,  0   ])
      yT = min([ ind[1,i]+1, Ny-1 ])

      L=IMG[xL, ind[1,i]] ; left
      R=IMG[xR, ind[1,i]] ; right
      B=IMG[ind[0,i], yB] ; bottom
      T=IMG[ind[0,i], yT] ; top
      
      ;L=IMG[ind[0,i]-1, ind[1,i]] ; left
      ;R=IMG[ind[0,i]+1, ind[1,i]] ; right
      ;B=IMG[ind[0,i], ind[1,i]-1] ; bottom      
      ;T=IMG[ind[0,i], ind[1,i]+1] ; top
      
      NN = [L,R,B,T]
      N = total(NN ne 0)
      if N ge 1 then begin 
      
        IMG_[ind[0,i], ind[1,i]]=total(NN)/float(N)
      ;  count = count +1
        
      endif 
    endfor
      
    ;print, 'empty pixels: ', n_elements(w), 'fixed: ', count
            
  endif else IMG_=IMG
  
  return, IMG_
   
End