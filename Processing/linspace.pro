
function linspace, range, n

  ;+
  ; NAME:
  ;     linspace
  ;
  ; PURPOSE:
  ;     returns a 1D array of n unoformly spaced integers within the provided range
  ;     
  ; CALLING SEQUENCE:
  ;    arr = linspace(range, n) 
  ;
  ; INPUTS:
  ;     
  ;    range  - 2-element array containing the minimum and the maximum values of the output array 
  ;    n      - number of elements in the output array 
  ;
  ; OUTPUTS:
  ;   
  ;   arr  - resulting array containing n unoformly spaced integers ranging from range[0] to range[1].
  ;          The uniform spacing between consecutive arr elements is exact if:
  ;             (range[1]-range[0])/(n-1) is integer
  ;          and/or    
  ;             either range[] or n are real (in which case "arr" is a floating point array)
  ;              
  ;          Otherwise, the spacing is approximate.   
  ;          
  ;           
  ;   The uniform spacing is approximate
  ;
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLES:
  ;   print, linspace([1,11], 5) ; approximate spacing, integer output
  ;       1       3       6       8      11
  ;   print, linspace([1,11], 5.0) ; exactspacing, real output
  ;       1.00000      3.50000      6.00000      8.50000      11.0000    
  ;   print, linspace([1,13], 5) ; exact spacing, integer output
  ;        1       4       7      10      13
  ;        
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-

  arr = indgen(n)*(range[1]-range[0])/(n-1) + range[0]
  
  return, arr
  
End