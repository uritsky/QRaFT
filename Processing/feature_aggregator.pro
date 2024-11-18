

function feature_aggregator, features, Nx, Ny, XYCenter
  
  ;+
  ; NAME:
  ;     feature_aggregator
  ;
  ; PURPOSE:
  ;     Creates a set of 2D arrays containing aggregated parameters based on local orientation angles at each image location involved in detected feature 
  ;
  ; CALLING SEQUENCE:
  ;     angles = feature_aggregator(features, Nx, Ny, XYCenter)
  ;
  ; INPUTS:
  ;     features    - array of structures returned by blob_stat_to_features(), describes parameters of detected coronal features
  ;     Nx, Ny      - horizontal and vertical sizes of the original image
  ;     XYCenter    - 2-element array [x0, y0] containing the horizontal (x0) and vertical (y0) positions of the solar disk center, in origianl pixel units
  ;
  ; OUTPUTS:
  ;     angles      - output structure including teh following 2D arrays (with the same dimensions as the original processed image):
  ;         angles.img_n    - array containing the number of features passing through a given pixel. This number shows how many 
  ;                           features detected using different combinations of tracing parameters overlap at a given location.
  ;         angles.img_avr  - array of ensemble-averaged orientation angles resulting from multiple tracing runs with different settings.
  ;         angles.img_sd   - array of standard deviations of the ensemble-averaged angles characterizing the disagreement of the tracing results at each location.
  ;         angles.img_rad  - array of relative orientation angles measuring the departures of the feature orientation from the local radial direction. 
  ;                           The relative angle is 0 if the feature is strictly radial at a given pixel.

  ;
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ;     
  ;     angles = feature_aggregator(features, Nx, Ny, c.XYCenter)
  ;     
  ;     (see QRaFT() for more details)
  ;
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-

  
  img_angles = dblarr(Nx, Ny)
  img_angles_2 = dblarr(Nx, Ny)

  img_n = dblarr(Nx, Ny)
  img_avr = dblarr(Nx, Ny)
  img_sd = dblarr(Nx, Ny)
  img_rad = dblarr(Nx, Ny)
  
  for i=0, n_elements(features)-1 do begin
    
    for k=0, features[i].n_nodes-2 do begin
      x = features[i].angles_xx_r[k]
      y = features[i].angles_yy_r[k]
      angle = features[i].angles_p[k]
      
      img_angles[x,y] = img_angles[x,y] + angle
      img_angles_2[x,y] = img_angles_2[x,y] + angle^2      
      img_n[x,y] = img_n[x,y]+1           
      img_rad[x,y] = feature_angles(y - XYCenter[1], x - XYCenter[0])
      
    endfor    
    
  endfor
  
  w = where(img_n gt 0)
  
  img_avr[w] = img_angles[w]/img_n[w]
  
  img_sd[w] = sqrt(img_angles_2[w]/img_n[w] - (img_avr[w])^2)
    
  return, {img_avr:img_avr, img_n:img_n, img_sd:img_sd, img_rad:img_rad}   
  
End