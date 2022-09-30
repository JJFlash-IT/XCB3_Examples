sub reset_game() SHARED STATIC
  dim drop_this as BYTE
  framecount = 0
  framecount_shooting = 0
  event = 0
  
  enemy_bullet_on(0) = 0
  enemy_bullet_on(1) = 0
  enemy_bullet_on(2) = 0
  sound_phase = 3

  ' -- clear sprite detection registers
  ' -- by reading their values
  drop_this = peek(SPR_SPR_COLL)
  drop_this = peek(SPR_BG_COLL)

  ship_pos = 176
  poke SPR_TE0_X, cbyte(ship_pos)
  poke SPR_X_MSB, peek(SPR_X_MSB) AND %11111110 ' reset MSB of sprite 0
  poke SPR_TE0_SHAPE, 255

  poke SPR_TE6_X, cbyte(ufo_pos)
  if ufo_pos > 255 then
    poke SPR_X_MSB, peek(SPR_X_MSB) OR  %01000000 'set MSB of sprite 6
  else
    poke SPR_X_MSB, peek(SPR_X_MSB) AND %10111111 'turn off MSB of sprite 6
  end if

  call update_backup_ships()

  for i as BYTE = 0 to 15
    poke SPR_CNTRL, i AND %00000001 'turn sprite 0 off and on...
    for j as BYTE = 0 to 12 'was 25, this loop is slower than using XCB2's WATCH
      do : loop until cbyte(scan()) = 0
    next j
  next i

   poke SPR_CNTRL, %01000001 'turn sprite 6 and 0 on
end sub
