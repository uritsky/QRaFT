

PRO qraft_fig_script, slice_ind

  print, '---------------------------------------------'
  print, 'Slice index: ', slice_ind

  dir_COR1  = "C:\Users\vadim\Documents\IDL\QRaFT\3.0\Test files\"
  
  fig_dir = dir_COR1 + "figures\" + string(slice_ind, format='(I2.2)')+'\'

  if file_test(fig_dir) eq 0 then file_mkdir, fig_dir   
  
  
  ff_COR1_ne = file_search(dir_COR1+'*\*ne.fits')
  ff_COR1_B1 = file_search(dir_COR1+'*\*By.fits')
  ff_COR1_B2 = file_search(dir_COR1+'*\*Bz.fits')
  ff_COR1_ne_los = file_search(dir_COR1+'*\*ne_LOS.fits')
  ff_COR1_pB = file_search(dir_COR1+'*\*pB.fits')
  ff_COR1_img = file_search(dir_COR1+'*\*med.fts')


  const_str = 'px=10.88 cx=256 cy=256 dp=1 dr=2 sx=12 sp=3 sr=15 ps=2 pd=5 np=20 nr=10 p1=0.8 p2=0.99 r1=130 r2=0 vn=10 vi=0.2 vc=0.005'
    
  qres_mas_ne     =  qraft(ff_COR1_ne[slice_ind],     const_str,  fname_B1=ff_COR1_B1[slice_ind],   fname_B2=ff_COR1_B2[slice_ind] )
  qres_mas_ne_LOS =  qraft(ff_COR1_ne_LOS[slice_ind], const_str,  fname_B1=ff_COR1_B1[slice_ind],   fname_B2=ff_COR1_B2[slice_ind] )
  qres_mas_pB     =  qraft(ff_COR1_pB[slice_ind],     const_str,  fname_B1=ff_COR1_B1[slice_ind],   fname_B2=ff_COR1_B2[slice_ind] )
  qres_COR1_pB    = qraft(ff_COR1_img[slice_ind],     const_str,  fname_B1=ff_COR1_B1[slice_ind],   fname_B2=ff_COR1_B2[slice_ind] ) 
  
  
  B1 = readfits(ff_COR1_B1[slice_ind], /silent)
  B2 = readfits(ff_COR1_B2[slice_ind], /silent)
  
  save, filename=fig_dir+'results.sav', const_str, qres_mas_ne, qres_mas_ne_LOS, qres_mas_pB, qres_COR1_pB


  qres_struc  = {qres_mas_ne:qres_mas_ne, qres_mas_ne_LOS:qres_mas_ne_LOS, qres_mas_pB:qres_mas_pB, qres_COR1_pB:qres_COR1_pB}
  
  suffix_arr = ['MAS_density', 'MAS_LOS_density', 'MAS_pB', 'COR1_pB']
   
  ;---------------------------------------------------
  ; Method (2nd order azimuthal differencing)
  
  qraft_fig_differencing, fig_dir=fig_dir
  
  for i=0,3 do begin
    
    ; Image processign steps
    qraft_fig_images, qres_struc.(i), suffix_arr[i], fig_dir=fig_dir
    
    ; Blob tracing in polar coordinates
    qraft_fig_tracing, qres_struc.(i), suffix_arr[i], fig_dir=fig_dir
    
    ; Plotting all traced blobs versus the validated blobs
    qraft_fig_validation, qres_struc.(i), suffix_arr[i], fig_dir=fig_dir

    ; Plotting features vs magnetic field lines
    qraft_fig_B_alignment, qres_struc.(i), B1, B2, suffix_arr[i], fig_dir=fig_dir

    ; Mapping misalignment angle vs B-field lines
    qraft_fig_B_errors, qres_struc.(i), B1, B2, suffix_arr[i], fig_dir=fig_dir

    ; Error histograms and statistics
    qraft_fig_error_stat, qres_struc.(i), B1, B2, suffix_arr[i], fig_dir=fig_dir
    

  endfor
  
  
;  ;---------------------------------------------------
;  ; Image processign steps
;     
;  qraft_fig_images, qres_mas_ne, 'MAS density', fig_dir=fig_dir
;  qraft_fig_images, qres_COR1_img, 'COR1 pB', fig_dir=fig_dir
;
;  ;---------------------------------------------------
;  ; Blob tracing in polar coordinates
;   
;  qraft_fig_tracing, qres_mas_ne, 'MAS density', fig_dir=fig_dir
;  qraft_fig_tracing, qres_COR1_img, 'COR1 pB', fig_dir=fig_dir
;
;  ;---------------------------------------------------
;  ; Plotting all traced blobs versus the validated blobs
;  
;  qraft_fig_validation, qres_mas_ne, 'MAS density', fig_dir=fig_dir
;  qraft_fig_validation, qres_COR1_img, 'COR1 pB', fig_dir=fig_dir
;
;  ;---------------------------------------------------
;  ; Plotting features vs magnetic field lines
;  
;  qraft_fig_B_alignment, qres_mas_ne, B1, B2, 'MAS density', fig_dir=fig_dir
;  qraft_fig_B_alignment, qres_COR1_img, B1, B2, 'COR1 pB', fig_dir=fig_dir
;  ;  
;
;  ;---------------------------------------------------
;  ; Mapping misalignment angle vs B-field lines 
;  
;  qraft_fig_B_errors, qres_mas_ne, B1, B2, 'MAS density', fig_dir=fig_dir
;  qraft_fig_B_errors, qres_COR1_img, B1, B2, 'COR1 pB', fig_dir=fig_dir
;  
;  ;---------------------------------------------------
;  ; Error histograms and statistics
;  
;  qraft_fig_error_stat, qres_mas_ne, B1, B2, 'MAS density', fig_dir=fig_dir
;  qraft_fig_error_stat, qres_COR1_img, B1, B2, 'COR1 pB',fig_dir=fig_dir
;  
;  ;---------------------------------------------------
      
End