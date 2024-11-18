
function angles_vs_B, img_angles, img_n, B1, B2, XYCenter
  ; (B1,B2: in-plane components of B field, e.g. By, Bz),
  ; img_angles: 2D array of mean angles

  ;+
  ; NAME:
  ;   angles_vs_B
  ;
  ; PURPOSE:
  ;     Calculates plane-of-sky (POS) misalignment angles between QRaFT features 
  ;     and local magnetic field directions from a coronal simulation
  ;
  ; CALLING SEQUENCE:
  ;     angle_errors = angles_vs_b(img_angles, img_n, B1, B2, XYCenter)
  ;
  ; INPUTS:
  ;     img_angles  - 2D array containing local mean orientaiton angles of successfully traced QRaFT features. 
  ;                   The angles are typically estimateed based on multiple QRaFT runs.                     
  ;                   Array elements no QRaFT features are filled with 0s.  
  ;     img_n       - 2D array containing the number of QRaFT features used for the calculation 
  ;                   of the orientation angle. 
  ;                   Thus, e.g., img_n[x,y]=0 means that not a single feature passed through the pixel (x,y) and thus
  ;                   no angle calculiton was possible; img_n[x,y]=2 means that 2 features detected using distinct sets of tracing parameters
  ;                   were found at the given location.
  ;     B1          - 2D array containing x-components of the magnetic field projected on to the POS 
  ;     B2          - 2D array containing y-components of magnetic field projected on to the POS            
  ;                 
  ;         NOTE: the arrays img_angles, img_n, B1 abd B2 must have the same size.  
  ;
  ;     XYCenter    - 2-element array containing array indices of the solar disk center
  ;
  ; OUTPUTS:
  ;     2D array with misalignment angles. At each location, the misalignment angle is zero if the feature is perfectly aligned with the POS projection 
  ;     of the magnetic field vector at that point.
  ;      
  ;     Empty pixels with no misalignment angle measurements can be identified using the img_n[x,y]=0 condition.
  ;
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ;     
  ;     blob_stat = trace_blobs(IMG_d2_phi_enh, p_arr, rho_min_arr, 5)
  ;     features = blob_stat_to_features(blob_stat, d_phi, d_rho, rho_min, XYCenter, abs(IMG_orig))
  ;     angles = feature_aggregator(features, Nx, Ny, c.XYCenter)
  ;     B1 = readfits(fname_B1, /silent)
  ;     B2 = readfits(fname_B2, /silent)
  ;     
  ;     IMG_angles_err = angles_vs_b(angles.img_avr, angles.img_n, B1, B2, XYCenter)
  ;     
  ;     See QRaFT.pro for more details.
  ;
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-



  ; ensuring that the  B-vector is always outward
  sz = size(B1, /dim)
  Nx = sz[0] & Ny = sz[1]
  
  img_angle_err = fltarr(Nx,Ny)
  
  R1 = fltarr(Nx,Ny) & R2 = R1 ; 2D coordinate arrays
  for x=0, Nx-1 do $
    for y=0, Ny-1 do begin
    R1[x,y] = x - XYCenter[0]
    R2[x,y] = y - XYCenter[1]
  endfor
 
  mask = fix( (B1*R1 + B2*R2) gt 0 ) ; 2D binary array filled with 1s (0s) for outward (inward) B field
  w = where(mask le 0)
  if w[0] ne -1 then mask[w] = -1 ; 0-> -1
  
  Bx = B1*mask & By = B2*mask ; flipping the field where necessary

  fx = cos(img_angles) & fy = sin(img_angles) ; 2D arrays of outward unit vector components corresponding to local angles  
  
  w = where(img_n gt 0)
  for i=0, n_elements(w)-1 do begin ;iterating through all pixels containing measured angles 
    
    x = R1[w[i]] + XYCenter[0]
    y = R2[w[i]] + XYCenter[1]

    v1 = [fx[x,y], fy[x,y]]
    v1_mag = sqrt(total(v1^2))
    
    v2 = [Bx[x,y], By[x,y]] ; outward B
    v2_mag = sqrt(total(v2^2))
    
    ;img_angle_err[x,y] = asin( ( v1[0]*v2[1] - v1[1]*v2[0]  ) / (v1_mag*v2_mag)  )
    
    img_angle_err[x,y] = asin( ( v1[1]*v2[0] - v1[0]*v2[1]  ) / (v1_mag*v2_mag)  )
          
  endfor

  return, img_angle_err

End
