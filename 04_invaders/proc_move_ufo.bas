' -----------------------------------
' -- move ufo
' -----------------------------------

sub move_ufo() SHARED STATIC
  if ufo_hit then
    framecount_ufo = framecount_ufo + 1
    if framecount_ufo > 74 then
      ufo_on = 0
      ufo_pos = 370
      gosub pos_ufo
      framecount_ufo = 0
      ufo_hit = 0
      poke SPR_TE6_SHAPE, 246
    end if
    exit sub
  end if
  
  if ufo_on then
    ufo_pos = ufo_pos - 1
    if ufo_pos < 8 then ufo_on = 0 : exit sub
    gosub pos_ufo
  else
    framecount_ufo = framecount_ufo + 1
    if framecount_ufo > 999 then
      ufo_on = 1
      ufo_pos = 370
      framecount_ufo = 0
    end if
  end if
  
  exit sub

pos_ufo:
    poke SPR_TE6_X, cbyte(ufo_pos)
    if ufo_pos > 255 then
      poke SPR_X_MSB , peek(SPR_X_MSB) OR %01000000 'turn on MSB of sprite 6
    else
      poke SPR_X_MSB, peek(SPR_X_MSB) AND %10111111 'turn off MSB of sprite 6
    end if
    return
end sub
