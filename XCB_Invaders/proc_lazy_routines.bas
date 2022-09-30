' -- put code here that
' -- can run when there's enough
' -- raster time

sub lazy_routines() SHARED STATIC
  if addscore > 0 then
    score = score + addscore
    textat 6, 0, score
    addscore = 0
  end if

  call update_enemy_map_bottom()
end sub
