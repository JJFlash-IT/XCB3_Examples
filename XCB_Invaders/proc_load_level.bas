' -----------------------------------
' -- load level
' -----------------------------------

sub load_level() SHARED STATIC
  for i as BYTE = 0 to 4
    for j as BYTE = 0 to 11
      enemy_map(i * 12 + j) = map1(i)
    next j
  next i
  bottom_row = 13
  scroll_bottom_limit = 201 'was 202
  enemy_posx = 8
  enemy_posy = 0
  spos = 1224 + cword(enemy_posy) * 40 + enemy_posx
  
  scroll = 0 'this was originally not reset!
end sub
