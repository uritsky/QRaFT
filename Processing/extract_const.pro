function extract_const, s, par, type=type

  ;+
  ; NAME:
  ;     extract_const
  ;
  ; PURPOSE:
  ;     Exctracts a single parameter from the formatted string "s" containing full set of processing parameters.
  ;     Called by read_const_string().
  ;
  ; CALLING SEQUENCE:
  ;        value = extract_const(s, par, type=type)
  ;
  ; INPUTS:
  ;     s         - formatted string containing values of processing parameters.
  ;     par       - string with the name of the parameter to be extracted
  ;     type      - string with the IDL type of the output value. Allowed values: "f", "i"
  ;                 Optional, default value "i". 
  ;
  ; OUTPUTS:
  ;     Numerical value of the requester parameter
  ;     
  ; RESTRICTIONS:
  ;     none
  ;
  ; EXAMPLE:
  ;          
  ;     rho_min     = extract_const(s, 'r1', type='i')
  ;    
  ; 
  ; MODIFICATION HISTORY:
  ;       V. Uritsky, 2024 -
  ;-

  if n_elements(type) eq 0 then type='f'

  i1 = strpos(s, par)+strlen(par)+1
  i2 = strpos(s, ' ', i1)
  if i2 eq -1 then i2 = strlen(s)

  if type eq 'f' then v = float(  strmid(s, i1, i2-i1))
  if type eq 'i' then v = fix(    strmid(s, i1, i2-i1))

  return, v

End