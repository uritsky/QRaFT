
function QRaFT, fname, const_str, fname_B1=fname_B1, fname_B2=fname_B2 

  ;+
  ; NAME:
  ;     QRaFT
  ;
  ; PURPOSE:
  ;     Main executable modle of QRaFT 3.0 package
  ;
  ; CALLING SEQUENCE:
  ;     results = QRaFT(fname, const_str, fname_B1=fname_B1, fname_B2=fname_B2)
  ;
  ; INPUTS:
  ;     fname         - name of FITS file containing processed solar image. The image must be uniformly binned.
  ;     const_str     - formatted string og processign parameters (SEE BELOW)
  ;     
  ;     fname_B1      - name of FITS file with a simulation-based magnetic field component along the horizontal image direciton.                    
  ;     fname_B2      - name of FITS file with a simulation-based magnetic field component along the vertical image direciton
  ;                     Note: "fname_B1" and "fname_B2" are optional. If these keywords are provided, QRaFT
  ;                     perform a comparison between the orientation of the detected image features
  ;                     and the magnetic field lines projected onto the plane of sky. 
  ;                     If not, the comparison with the B field will be skipped but the feature detection will 
  ;                     still proceed. 
  ; OUTPUTS:
  ;     results - output structure containing processing results:
  ;         results.fname         -   Name of the processed file (full path) 
  ;         results.header        -   String array with the copy of the FITS header of the processed image file            
  ;         results.const_str     -   String of processing parameters used for the image segmentation   
  ;         results.c             -   Structure of processing parameters.
  ;                                   Returned by read_const_string().
  ;         results.x             -   1D array of horizontal positions of pixels of the original image (in c.pix_size units) 
  ;         results.y             -   1D array of dimensional vertical positions of pixels of the original image (in c.pix_size units)
  ;         results.phi           -   1D array of azimuthal positions (phi coordinates) of the pixels in the polar-transformed image (in radians) 
  ;         results.rho           -   1D array of radial positions (rho coordinates) of the pixels in the polar-transformed image (in c.pix_size units)         
  ;         results.p_arr         -   1D array of probability vaues used to compute percentile thresholds 
  ;         results.rho_min_arr   -   1D array of indices defining the position of the lower coronal boundary (in rho pixel inits)
  ;         results.blob_indices  -   3D array containing first and last label values of the pixel blobs (features) identified using differfent
  ;                                   combinations of p_arr[k] and rho_min_arr[i]. The order of the array direcitons: blob_indices[[blob_ind_1, blob_ind_2],k,i].
  ;                                   Returned by trace_blobs().   
  ;         results.blob_stat     -   Structure containing 1D arrays of geometric parameters of the detected blobs (features).
  ;                                   Returned by trace_blobs().
  ;         results.features      -   array of structures containing the paramemters of the detected blobs, compatible with QRaFT 1.0 amd 2.0. 
  ;                                   Returned by blob_stat_to_features();                                   
  ;         results.img_orig      -   2D array containing smoothed and radially detrended version of the original image from file "results.fname".
  ;                                   Coordinate system of the original image.
  ;         results.img_orig_p    -   "img_orig" transformed into polar coordinates and subject to smoothing and hole-patching.
  ;                                   Returned by  rect_to_polar (plus additional processing steps). Plane polar coordinate system.
  ;         results.img_d2_phi    -   Azimuthally-differenced version of "img_orig_p". 
  ;                                   Returned by azimuthal_diff(). Plane polar coordinate system.
  ;         results.img_d2_phi_enh -  Azimuthally-detrended version of "img_d2_phi". 
  ;                                   Returned by detrend_azimuthal(). Plane polar coordinate system. 
  ;         results.img_angles    -   2D array containing ensemble-averaged orientation angles resulting from multiple segmentaion runs with different settings. 
  ;                                   Returned by feature_aggregator(). Coordinate system of the original image.
  ;         results.img_angles_n  -   2D array containing the number of features passing through a given pixel.   
  ;                                   Returned by feature_aggregator(). Coordinate system of the original image.
  ;         results.img_angles_sd -   2D array containing standard deviations of the ensemble-averaged angles characterizing the disagreement of the tracing results at each location. 
  ;                                   Returned by feature_aggregator(). Coordinate system of the original image.
  ;         results.img_angles_rad -  2D array of relative orientation angles measuring the departures of the feature orientation from the local radial direction. 
  ;                                   Returned by feature_aggregator(). Coordinate system of the original image.
  ;                                   
  ;         results.B1            -   2D array of the simulation-based magnetic field components in the horizontal POS direciton of the processed image.
  ;                                   Coordinate system of the original image.
  ;                                   
  ;         results.B2            -   2D array of the simulation-based magnetic field components in the vertical POS direciton of the processed image.           
  ;                                   Coordinate system of the original image.
  ;         results.img_angles_err -  2D array of plane-of-sky misalignment angles between the detected features and the magnetic field from a coronal simulation. 
  ;                                   Returned by angles_vs_b(). Coordinate system of the original image.
  ;                                   
  ;                 Note: if the "fname_B1" and "fname_B1" keywords have not been provided, the tags "B1", "B2" and "img_angles_err" are set to -1. 
  ;                  
  ;         
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ; 
  ;     ; directory of data files:
  ;     
  ;     dir_test = "c:\Users\vadim\Documents\IDL\QRaFT\3.0\Test files\"
  ;     
  ;     ; data file names:
  ;     f_COR1_ne = dir_test + '2017_09_11_COR1_PSI_ne.fits'
  ;     f_COR1_B1 = dir_test + '2017_09_11_COR1_PSI_By.fits'
  ;     f_COR1_B2 = dir_test + '2017_09_11_COR1_PSI_Bz.fits'
  ;     
  ;     ; procesing parameters:
  ;     const_str = 'px=10.88 cx=256 cy=256 dp=1 dr=2 sx=12 sp=3 sr=15 ps=2 pd=5 np=20 nr=10 p1=0.8 p2=0.99 r1=110 r2=0 w1=2 w2=10 l1=10 l2=30 vn=10 vi=0.2 vc=0.005'
  ;
  ;     ; Image segmentaion using QRaFT 3.0:
  ;     
  ;     qres = QRaFT(f_COR1_ne, const_str, fname_B1 = f_COR1_B1, fname_B2 = f_COR1_B2)
  ;     
  ;     ; Plotting some of the results:
  ;     
  ;     B1= readfits(f_COR1_B1, /silent) & B2= readfits(f_COR1_B2, /silent)
  ;     
  ;     qraft_fig_B_alignment, qres, B1, B2, '_test', fig_dir = dir_test
  ;     qraft_fig_error_stat, qres, B1, B2, '_test', fig_dir = dir_test
  ;
  ;
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-
   
   
  ;-------- Processing parameters ----------------

  ;
  ; example of a formatted parameter string: 
  ;   'px=10.88 cx=256 cy=256 dp=1 dr=2 sx=12 sp=3 sr=15 ps=2 pd=5 np=20 nr=10 p1=0.8 p2=0.99 r1=110 r2=0 w1=2 w2=10 l1=10 l2=30 vn=10 vi=0.2 vc=0.005'
  ; 
  ; Note: the order of the parameters is arbitrary.
  ; 
  ; 
  ; Parameters of the processed image: 
  ; px  - pixel size [dimensional length units]
  ; cx  - x-position of the image center [orig. pixels]
  ; cy  - y-position of the image center [orig. pixels]
  
  ; Parameters used for polar coordinate transformation:
  ; dp  - azimuthal bin size [degrees]
  ; dr  - radial bin size [orig. pixels]
  ; r1  - minimum radial distance [orig. pixels]
  ; r2  - maximum radial distance [orig. pixels]. Set r2=0 for largest available distance
  
  ; Smoothing & noise reduction parameters:
  ; sx  - linear size of isotropic smoothing window applied to original image [orig. pixels]
  ; sp  - azimuthal size of smoothing window applied to polar image [phi pixels]
  ; sr  - radial size of smoothing window applied to polar image [rho pixels]
   
  ; Parameters used for azimuthal differencing and detrending:
  ; ps  - shift in phi direction used for azimuthal differencing [phi pixels]
  ; pd  - azimuthal scale used for detrending [phi pixels]

  ; Feature tracing parameters:
  ; np  - number of probability thresholds
  ; nr  - number of inner boundaries (in rho direction) used for tracing
  ; p1  - minimum probability used for percentile thresholding (0..1)
  ; p2  - maximum probability used for percentile thresholding (p1..1)

  ; Feature validation parameters:
  ; w1  - minimum phi width
  ; w2  - maxumum phi width
  ; l1  - minimum rho length
  ; l2  - maximum rho length
  ; vn  - minimum number of feature nodes along rho direciton (feature length) [rho pixels]
  ; vi  - minimum median feature intensity [units of intensity of azimutally differenced image]
  ; vc  - maximum allowed feature curvature [relative units]
    
  ;---------------------------------------------- 
    
  ; EXAMPLE:
  ; 
  ; dir_COR1 = "c:\Users\vadim\Documents\SCIENCE PROJECTS\N Arge\PSI\Coaligned_COR1_PSI_FORWARD\slices_05_22_2023"
  ; ff_COR1_ne = file_search(dir_COR1+'\*\*ne.fits') & ff_COR1_B1 = file_search(dir_COR1+'\*\*By.fits') & ff_COR1_B2 = file_search(dir_COR1+'\*\*Bz.fits')
  ; const_str = 'px=10.88 cx=256 cy=256 dp=1 dr=2 sx=12 sp=3 sr=15 ps=2 pd=5 np=20 nr=10 p1=0.8 p2=0.99 r1=110 r2=0 w1=2 w2=10 l1=10 l2=30 vn=10 vi=0.2 vc=0.005'
  ; 
  ; qres = QRaFT(ff_COR1_ne[0], const_str, fname_B1 = ff_COR1_B1[0], fname_B2 = ff_COR1_B2[0])
  ; B1= readfits(ff_COR1_B1[0], /silent)
  ; B2= readfits(ff_COR1_B2[0], /silent)
  ; qraft_fig_B_alignment, qres, B1, B2, '_test'
  ; qraft_fig_error_stat, qres, B1, B2, '_test'
  ; 
  
  ;----------------------------------------------
  
    
  c = read_const_string(const_str)
  
  ;-------- opening file -------------
  ;print, 'Processed file: ', file_basename(fname)  
  IMG_orig = readfits(fname, header, exten_no=exten_no, /silent)
     
  sz = size(IMG_orig, /dim) & Nx = sz[0] & Ny = sz[1]
  ;c.XYCenter = [Nx, Ny] / 2.0
  X = (findgen(Nx) - c.XYCenter[0])*c.pix_size
  Y = (findgen(Ny) - c.XYCenter[1])*c.pix_size
  
  ;-------- IMAGE PREPROCESSING -------------

  ; -------------------------------------------
  ; 1. Initial processing in rect. coordinates
  ; -------------------------------------------
  
  ; initial smoothing: 
  if c.smooth_xy gt 1 then IMG_orig = median(IMG_orig, c.smooth_xy)  
  
  ; detrending:  
  IMG_orig = radial_detrending(abs(IMG_orig), c.XYCenter)
  
  ; removing near-Sun region:
  for i=0,Nx-1 do for k=0, Ny-1 do $
    if (i - c.XYCenter[0])^2 + (k - c.XYCenter[1])^2 lt c.rho_min^2 then IMG_orig[i,k] = 0.0
   
  ; -------------------------------------------
  ; 2. Main processing in polar coordinates
  ; -------------------------------------------
  
  ; Rectang. to polar transform
  rect_to_polar, img_orig, c.XYCenter, c.d_phi, c.d_rho, IMG_orig_p, Rho_range=c.Rho_range, X_p=X_p, Y_p=Y_p, Phi_p=Phi_p, Rho_p=Rho_p
      
  szp = size(IMG_orig_p, /dim)
  N_phi = szp[0] 
  N_rho = szp[1]
  
  Phi = reform((Phi_p[*,0]))
  Rho = reform((Rho_p[0,*]))*c.pix_size
  
  ;Xp = findgen(N_phi)*c.d_phi
  ;Yp = (findgen(N_rho) + c.Rho_range[0])*c.d_rho  
  
  ; Fill binning gaps (if any) in polar image:
  IMG_orig_p = patch_image_holes(IMG_orig_p) ; help, count
  
  ; Smoothing
  IMG_orig_p = smooth_polar(IMG_orig_p, c.smooth_phi_rho)
    
  ; 1st order azimuthal differencing and smoothing 
  ;IMG_d1_phi_ = shift(IMG_orig_p_, [c.phi_shift,0]) - IMG_orig_p_
  ;IMG_d1_phi_ = smooth(IMG_d1_phi_, c.smooth_phi_rho)
  ;IMG_d2_phi_ = shift(IMG_d1_phi_, [phi_shift,0]) - IMG_d1_phi_
   
   
  ; One-step 2nd order azimuthal difference in polar coordinates and smoothing:

  IMG_d2_phi = azimuthal_diff(IMG_orig_p, c.phi_shift, c.smooth_phi_rho) 
  ;IMG_d2_phi = shift(IMG_orig_p, [c.phi_shift,0]) + shift(IMG_orig_p, [-c.phi_shift,0]) - 2*IMG_orig_p
  ;IMG_d2_phi = smooth(IMG_d2_phi,  c.smooth_phi_rho)
  
;  ; phi - detrending of unsigned 2nd-order difference: 
  IMG_d2_phi_enh = detrend_azimuthal(abs(IMG_d2_phi), c.phi_detr)
    
  ; -------------------------------------------
  ; 3. Blob detection and interpolation
  ; -------------------------------------------
  ;  
  ; Array of percentile thresholds:
  p_arr = linspace(c.p_range, c.n_p)

  ; Array of min. rho levels:
  rho_min_arr = linspace([1, N_rho*4/5], c.n_rho)
   
  ; blob detection:
  ;blob_stat = trace_blobs(IMG_d2_phi_enh, p_arr, rho_min_arr, 5, IMG_lbl_arr=IMG_lbl_arr, blob_indices=blob_indices)
  
  blob_stat = trace_blobs(IMG_d2_phi_enh, p_arr, rho_min_arr, IMG_lbl_arr=IMG_lbl_arr, blob_indices=blob_indices)
  
  features = blob_stat_to_features(blob_stat, c.d_phi, c.d_rho, c.rho_min, c.XYCenter, abs(IMG_orig))
  
  intensity_min = c.int_min * mean(abs(IMG_orig[where(IMG_orig ne 0)])) 
  
  
  ;width_range = [2, 10] & length_range = [10, 30]
  ;     width_range   -     2-element array with the smallest and largest azimuthal width of the valid clusters (in pixel units).
  ;                         Optional, default value [2, 10].
  ;     length_range  -     2-element array with the smallest and largest radial length of the valid clusters (in pixel units).
  ;                         Optional, default value [10, 30].
     
  features = feature_validator(features, c.width_range, c.length_range, c.n_nodes_min, intensity_min, c.curv_max )
  
  angles = feature_aggregator(features, Nx, Ny, c.XYCenter)
  
  ;img_avr = patch_image_holes(res.img_avr)  
  
  if n_elements(fname_B1)*n_elements(fname_B2) ne 0 then begin    
    B1 = readfits(fname_B1, /silent)
    B2 = readfits(fname_B2, /silent)
    IMG_angles_err = angles_vs_b(angles.img_avr, angles.img_n, B1, B2, c.XYCenter)  
  endif else begin    
    B1 = -1
    B2 = -1
    IMG_angles_err = -1
  endelse
  
  ;+++++++++++++++++++++++++++++++++++++++++++++++
    qraft_results={fname:fname, header:header, const_str:const_str, c:c, X:X, Y:Y, Phi:Phi, Rho:Rho, $
      p_arr:p_arr, rho_min_arr:rho_min_arr, blob_indices:blob_indices, blob_stat:blob_stat, features:features, $
      IMG_orig:IMG_orig, IMG_orig_p:IMG_orig_p, IMG_d2_phi: IMG_d2_phi, IMG_d2_phi_enh:IMG_d2_phi_enh, $
      IMG_angles:angles.img_avr, IMG_angles_n:angles.img_n, IMG_angles_SD:angles.img_sd, IMG_angles_rad:angles.img_rad, $
      B1:B1, B2:B2, IMG_angles_err:IMG_angles_err}
    
  return, qraft_results
  
End
