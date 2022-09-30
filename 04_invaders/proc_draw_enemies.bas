' -----------------------------------
' -- draw enemies
' -----------------------------------

sub draw_enemies() SHARED STATIC
  dim pos_var as WORD : pos_var = 1224 + enemy_posx
  dim map_offset as BYTE : map_offset = 0
  dim shape as BYTE

  for y as BYTE = 0 to 4
    poke pos_var - 1, 32
    for x as BYTE = 0 to 11
      shape = enemy_map(map_offset)
      poke pos_var, shape
      pos_var = pos_var + 1
      shape = shape + 1
      poke pos_var, shape
      pos_var = pos_var + 1
      map_offset = map_offset + 1
    next x
    poke pos_var + 1, 32
    pos_var = pos_var + 56
  next y
end sub
