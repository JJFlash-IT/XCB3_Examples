' -----------------------------------
' -- shift enemies to the right
' -----------------------------------
sub rshift_enemies() SHARED STATIC
  memshift spos, spos + 1, enemy_map_length
  poke spos, 32
  spos = spos + 1
end sub

' -----------------------------------
' -- shift enemies down
' -----------------------------------
sub dshift_enemies() SHARED STATIC
  if (bottom_row + 1) = 19 then call ruin_shields() 'originally this was checked after spos = spos + 40, also bottom_row ended up being incremented TWICE, once here, then in main loop
  memshift spos, spos + 40, enemy_map_length
  memset spos, 24, 32
  spos = spos + 40
end sub

' -----------------------------------
' -- shift enemies to the left
' -----------------------------------
sub lshift_enemies() SHARED STATIC
  memcpy spos, spos - 1, enemy_map_length + 2
  spos = spos - 1
end sub
