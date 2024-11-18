

pro letterlabel1, str, size, vshift, color=color
  setkeyword, size, !P.charsize
  setkeyword, vshift, -0.015;0.01
  x0 = !x.window[0] + 0.005
  y0 = !y.window[1] + vshift
  xyouts,x0,y0, str, charsize=size, /normal, color=color
End