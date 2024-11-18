
function read_const_string, s_
 
  ;+
  ; NAME:
  ;     read_const_string
  ;
  ; PURPOSE:
  ;     Extracts processing parameters from the command-line string "s_"
  ;
  ; CALLING SEQUENCE:
  ;     c = read_const_string(s)
  ;
  ; INPUTS:
  ;     s_     - formatted string containing values of processing parameters.
  ;              All letters are converted to the low case. Called by the main module QRaFT().
  ;  
  ; OUTPUTS:
  ;     Structure of processing parameters loaded from the input striung "s_"
  ;
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ; 
  ;     const_str = 'px=10.88 cx=256 cy=256 dp=1 dr=2 sx=12 sp=3 sr=15 ps=2 pd=5 np=20 nr=10 p1=0.8 p2=0.99 r1=110 r2=0 w1=2 w2=10 l1=10 l2=30 vn=10 vi=0.2 vc=0.005'
  ;     
  ;     c = read_const_string(const_str)  
  ;     
  ;     See QRaFT() for the definitions of the processing parameters.
  ;
  ;
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-
 
  
  s = strlowcase(s_)
  
  ; center position and polar transformation
  XYCenter    = [extract_const(s, 'cx'), extract_const(s, 'cy')]
  pix_size    = extract_const(s, 'px') 
  
  d_phi       = extract_const(s, 'dp')*(!Pi/180)
  d_rho       = extract_const(s, 'dr')  

  rho_min     = extract_const(s, 'r1', type='i')
  rho_max     = extract_const(s, 'r2',  type='i') & if rho_max eq 0 then rho_max = min(XYCenter)
  rho_range   = [rho_min, rho_max]/d_rho
    
  ; smoothing parameters
  smooth_xy   = extract_const(s, 'sx', type='i')  
  smooth_phi  = extract_const(s, 'sp', type='i')
  smooth_rho  = extract_const(s, 'sr', type='i')
  
  ; azimuthal differencing and detrending
  phi_shift   = extract_const(s, 'ps')
  phi_detr     = extract_const(s, 'pd', type='i')
  
  ; tracing parameters
  n_p         = extract_const(s, 'np', type='i')
  n_rho       = extract_const(s, 'nr', type='i')
  p_min       = extract_const(s, 'p1')
  p_max       = extract_const(s, 'p2') 
  p_range     = [p_min, p_max]

  ; validation thresholds
  width_min = extract_const(s, 'w1')
  width_max = extract_const(s, 'w2')
  length_min = extract_const(s, 'l1')
  length_max = extract_const(s, 'l2')
  n_nodes_min = extract_const(s, 'vn', type='i')
  int_min     = extract_const(s, 'vi')
  curv_max    = extract_const(s, 'vc') 
  
  c ={pix_size:pix_size, XYCenter:XYCenter, d_phi:d_phi, d_rho:d_rho, rho_min:rho_min, $
      smooth_xy:smooth_xy, smooth_phi_rho:[smooth_phi, smooth_rho], $
      phi_shift:phi_shift, phi_detr:phi_detr, $
      n_rho:n_rho, n_p:n_p, p_range:p_range, rho_range:rho_range, $
      width_range: [width_min, width_max], length_range: [length_min, length_max], $
      n_nodes_min:n_nodes_min, int_min:int_min, curv_max:curv_max      }
       
  return, c
  
End