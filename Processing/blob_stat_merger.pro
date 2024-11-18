
function blob_stat_merger, bs1, bs2

  ;+
  ; NAME:
  ;     blob_stat_merger
  ;
  ; PURPOSE:
  ;     Concatenates (merges) two "blob_stat" structures by different calls og blob_labeler() inside trace_blobs() 
  ;     
  ;     
  ; CALLING SEQUENCE:
  ;      bs_merged = blob_stat_merger(bs1, bs2)
  ;
  ;
  ; INPUTS:
  ;     bs1, bs2     - structures of arrays of geometric parameters of the detected clusters
  ;                    measured by blob_labeler() based on two distinct sets of blob tracing settings.
  ;
  ;
  ; OUTPUTS:
  ;       The merged array of the "blob_stat" structures, with the same tag names as in the original structures
  ;
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ;      blob_stat_merged = blob_stat_merger(blob_stat_1, blob_stat_2);
  ;      (see blob_tracer(), blob_labeler() andblob_analyzer() for more details)
  ;
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-

  if n_elements(bs1) eq 0 then return, bs2

  width   = [bs1.width, bs2.width]
  length  = [bs1.length, bs2.length]
  area    = [bs1.area, bs2.area]
  phi     = [bs1.phi, bs2.phi]
  phi_fit = [bs1.phi_fit, bs2.phi_fit]
  rho     = [bs1.rho, bs2.rho]
  status  = [bs1.status, bs2.status]
  ; add more fields/tags as needed

  blob_stat = {width:width, length:length, area:area, phi:phi, phi_fit:phi_fit, rho:rho, $
    status:status}

  return, blob_stat

End
