function getpos, n_rows, n_cols, region=region, xyspace=xyspace

  pos = fltarr(n_rows,n_cols,4)
  if not keyword_set(region) then region = [0.05, 0.1, 0.98, 0.9] ;[0.1,0.1, 0.99, 0.90]
  if not keyword_set(xyspace) then xyspace = [0.08, 0.06] ; [0.04,0.06]

  xsize = (region[2]-region[0])/(1.0*n_cols)
  ysize = (region[3]-region[1])/(1.0*n_rows)
  for x=0,n_cols-1 do $
    for y=0,n_rows-1 do begin

    x1 = region[0] + x*xsize
    x2 = region[0] + (x+1)*xsize
    y1 = region[3] - (y+1)*ysize
    y2 = region[3] -  y*ysize
    pos[y,x,*] = [x1,y1,x2,y2] + [xyspace,0,0]

  endfor
  return, pos
End