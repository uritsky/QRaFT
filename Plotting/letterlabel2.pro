
pro letterlabel2, str, size=size, xyshift=xyshift, color=color
  setkeyword, size, !P.charsize
  setkeyword, xyshift, [0.01, 0.01]
  setkeyword, color, 0
  x0 = !x.window[0] + xyshift[0]
  y0 = !y.window[1] + xyshift[1]
  setcolors
  xyouts,x0,y0, str, charsize=size, /normal, color=color
End