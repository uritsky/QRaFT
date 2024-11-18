
function feature_validator, features, width_range, length_range, n_nodes_min, intensity_min, curvature_max 

  ;+
  ; NAME:
  ;     feature_validator
  ;
  ; PURPOSE:
  ;     filters the array of structures returned by blob_stat_to_features() according to a set of conditions,
  ;     in order to exclude unreliable image features
  ;
  ; CALLING SEQUENCE:
  ;     features_valid = feature_validator(features, width_range, length_range, n_nodes_min, intensity_min, curvature_max)
  ;
  ; INPUTS:
  ;     features      - array of structures returned by blob_stat_to_features(), describes parameters of detected coronal features
  ;     width_range   - 2-element array with the smallest and largest azimuthal width of (in phi pixel units)
  ;     length_range  - 2-element array with the smallest and largest radial length of valid features  (in rho pixel units)
  ;     n_nodes_min   - minimum number of interpolated nodes in a valid feature
  ;     intensity_min - minimum median intensity of a feature
  ;     curvature_max - maximum allowed curvature of a valid feature, estimated by the standard deviation
  ;                     of the local orientatin angles along the feature normalized by the number of nodes 
  ;                     in the feature. Short features with significant angle spread are removed by this condition.
  ;
  ; OUTPUTS:
  ;   features_valid  - the filtered version of input structure array "features" satisfying the applied filtering conditions
  ;
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ;   
  ;   const_str = 'px=10.88 cx=256 cy=256 dp=1 dr=2 sx=12 sp=3 sr=15 ps=2 pd=5 np=20 nr=10 p1=0.8 p2=0.99 r1=110 r2=0 w1=2 w2=10 l1=10 l2=30 vn=10 vi=0.2 vc=0.005'
  ;   c = read_const_string(const_str)
  ;   
  ;   features_vaid = feature_validator(features, c.width_range, c.length_range, c.n_nodes_min, intensity_min, c.curv_max ) 
  ;   
  ;   (see QRaFT() for more details)
  ;   
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-

  
   ;mean_IMG_orig = mean(abs(IMG_orig[where(IMG_orig gt 0)])) 
   
   ; length_min = length_range[0]
   
   w = where(  ( features.n_nodes gt n_nodes_min ) and $
    
               ( features.phi_width ge width_range[0] ) and $
               ( features.phi_width le width_range[1] ) and $                 
               ( features.rho_length ge length_range[0] ) and $
               ( features.rho_length le length_range[1] ) and $
    
               ( features.intensity gt intensity_min ) and $ 
               ( features.sd_angles/features.n_nodes lt curvature_max) $ 
             )
   
   if w[0] ne -1 then features = features[w]
    
   return, features

End