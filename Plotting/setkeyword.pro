PRO setkeyword, keyword, value
  ;if not keyword_set(keyword) then keyword=value
  if n_elements(keyword) eq 0 then keyword=value
End