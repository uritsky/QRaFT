PRO openps, fname, x_size, y_size
  ; example :
  ; openps, fname, 20.,30.
  setkeyword, fname, 'c:\q.eps'
  setkeyword, x_size, 20.0
  setkeyword, y_size, 30.0
  SET_PLOT, 'PS'
  DEVICE, /ENCAPSULATED, FILENAME = fname, /color, bits_per_pixel=8, xsize=x_size,  ysize=y_size, /TIMES
  !P.font=2 ; necessary for using postscript font "TIMES"; otherwise set to default !P.font = -1
End