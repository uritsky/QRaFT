
PRO plotframe, ylog=ylog
  ; plots a frame around the current plotting area using the current color

  xx = [ !x.crange[0], !x.crange[0], !x.crange[1], !x.crange[1], !x.crange[0] ]
  yy = [ !y.crange[0], !y.crange[1], !y.crange[1], !y.crange[0], !y.crange[0] ]
  if keyword_set(ylog) then yy = 10.0^yy
  plots, xx,yy
End