
function blob_stat_to_features, blob_stat, d_phi, d_rho, rho_min, XYCenter, IMG

  ;+
  ; NAME:
  ;     blob_stat_to_features
  ;
  ; PURPOSE:
  ;     Converts the structure of arrays "blob_stat" containing the parameters of the detected clusters 
  ;     in plane polar coordinates into the formatted array of strucutes "features" containing Cartesian metrics, 
  ;     used in the previous versions of the package (QRaFT 1.0, QRaFT 2.0).     
  ; 
  ; CALLING SEQUENCE:
  ;     features = blob_stat_to_features(blob_stat, d_phi, d_rho, rho_min, XYCenter, IMG)
  ;
  ; INPUTS:
  ; 
 ;     blob_stat  - a structure containing 1D arrays of geometric parameters of the detected blobs (features):
  ;         blob_stat.width   - feature width (size in the phi direction)
  ;         blob_stat.length  - feature length (size in the rho direction)
  ;         blob_stat.area    - feature area
  ;         blob_stat.rho_arr - 1D array of rho positions along the feature, ordered in the upward direction starting
  ;                             from the inner tracing boundary pres(rho_min_arr)
  ;         blob_stat.phi_arr - 1D array of phi values estimated at each rho_arr position
  ;         blob_stat.phi_fit - 1D array of interpolated phi values at each rho_arr position using a 2nd order polynomial fit
  ;         blob_stat.status  - the keyword returned by the IDL's poly_fit() function used for the polynomial fittiong
  ;           
  ;   d_phi       - azimuthal bin size, in radians      
  ;   d_rho       - radial pixel size, in origianl image pixels
  ;   rho_min     - minimum radial distance (inner boundary of the processed region), in origianl image pixels
  ;   XYCenter    - 2-element array [x0, y0] containing the horizontal (x0) and vertical (y0) positions of the solar disk center, in origianl pixel units
  ;   IMG         - 2D array with the original processed image in Cartesian coordinates

  ; OUTPUTS:
  ;   features    - The array of structures containing the paramemters of the detected blobs, compatible with QRaFT 1.0 amd 2.0. 
  ;                            
  ;         features[*].n_blobs     - total number of the detected (and validated) blobs
  ;         features[*].n_nodes     - number of interpolated nodes in a given feature
  ;         features[*].L           - feature length (Cartesian distance between the inner-most and the outer-most point in a feature), in original image pixels
  ;         features[*].phi_width   - feature width (size in polar the phi direction), in phi pixels
  ;         features[*].rho_length  - feature length (size in polar the rho direction), in rho pixels
  ;         features[*].sd_angles   - standard deviation of the orientation angles within a feature (equals 0 is the feature is perfectly straight)
  ;         features[*].intensity   - median intensity of the image pixels along the feature
  ;         
  ;         features[*].xx_r        - 1D array of x-positions of the feature nodes, in original image pixels 
  ;         features[*].yy_r        - 1D array of y-positions of the feature nodes, in original image pixels
  ;         features[*].angles_xx_r - 1D array of x-positions of the inter-nodal points at which the orientation angles are estimated, in original image pixels
  ;         features[*].angles_yy_r - 1D array of y-positions of the inter-nodal points at which the orientation angles are estimated, in original image pixels
  ;         features[*].angles_p    - 1D array of the orientation angles along the feature, in original image pixels
  ;         
  ;         NOTE: the 1D arrays are sorted by the ascending polar "rho" coordinate used in "blob_stat" 
  ;
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ;   const_str = 'px=10.88 cx=256 cy=256 dp=1 dr=2 sx=12 sp=3 sr=15 ps=2 pd=5 np=20 nr=10 p1=0.8 p2=0.99 r1=110 r2=0 w1=2 w2=10 l1=10 l2=30 vn=10 vi=0.2 vc=0.005'
  ;   c =  
  ;   features = blob_stat_to_features(blob_stat, d_phi, d_rho, rho_min, XYCenter, abs(IMG_orig))
  ;   (see QRaFT() for more details)
  ;   
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-

  n_blobs = n_elements(blob_stat.area) & n_nodes_max = n_elements(blob_stat.phi[0,*])
  n_nodes = intarr(n_blobs)
  rho_length = fltarr(n_blobs)
  phi_width = fltarr(n_blobs)
  xx_r = dblarr(n_blobs, n_nodes_max) & xx_r[*]=0 
  yy_r=xx_r & angles_xx_r = xx_r & angles_yy_r = yy_r & angles = xx_r 
  L = dblarr(n_blobs)
  
  for i=0, n_blobs-1 do begin
    N = blob_stat.length[i]
    n_nodes[i]=N
    
    phi_width[i] = blob_stat.width[i]
    rho_length[i] = blob_stat.length[i]    
          
    phi= d_phi*blob_stat.phi_fit[i,0:N-1]
    rho= d_rho*blob_stat.rho[i,0:N-1] + rho_min
    xx_r[i,0:N-1] = rho*cos(phi) + XYCenter[0]
    yy_r[i,0:N-1] = rho*sin(phi) + XYCenter[1]; XYCenter[0]

    L[i] = ( (xx_r[i,N-1]-xx_r[i,0])^2 + (yy_r[i,N-1]-yy_r[i,0])^2 )^0.5
            
    angles_xx_r[i,*] = (xx_r[i,*] + shift(xx_r[i,*], -1))/2.0 
    angles_yy_r[i,*] = (yy_r[i,*] + shift(yy_r[i,*], -1))/2.0    
    
    angles[i,*] = feature_angles(shift(yy_r[i,*],-1) - yy_r[i,*], shift(xx_r[i,*],-1) - xx_r[i,*] )
    ;angles[k] = feature_angles(yy_r[k+1]-yy_r[k], xx_r[k+1]-xx_r[k])
    
    angles_xx_r[i, N-1:-1] = 0 
    angles_yy_r[i, N-1:-1] = 0
    angles[i, N-1:-1] = 0
        
  endfor

  features= make_array(n_blobs, value = {xx_r: dblarr(n_nodes_max), yy_r: dblarr(n_nodes_max), $
                       angles_xx_r: dblarr(n_nodes_max), angles_yy_r: dblarr(n_nodes_max), angles_p:dblarr(n_nodes_max), $
                       intensity:0.0, n_nodes:0, L:0.0, sd_angles:0.0, rho_length:0.0, phi_width:0.0} )
  for i=0, n_blobs-1 do begin
    features[i].n_nodes = n_nodes[i]
    
    features[i].rho_length = rho_length[i]
    features[i].phi_width = phi_width[i]
        
    features[i].xx_r = xx_r[i,*] ;+ XYCenter[0]
    features[i].yy_r = yy_r[i,*] ;+ XYCenter[1]        
    features[i].L = L[i]
    
    features[i].intensity = median( IMG[features[i].xx_r[0:n_nodes[i]-1], features[i].yy_r[0:n_nodes[i]-1]] )
    
    features[i].angles_xx_r = angles_xx_r[i,*]
    features[i].angles_yy_r = angles_yy_r[i,*]
    features[i].angles_p = angles[i,*]
    if n_nodes[i] ge 3 then $ 
      features[i].sd_angles = stddev(angles[i,0:n_nodes[i]-2])
    
  endfor

  return, features 
End