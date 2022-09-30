' ------------------------------------
' -- move the player's ship and bullet
' ------------------------------------

sub move_ship() SHARED STATIC
  Dim joy as BYTE
  Dim joy_previous_fire as BYTE 'this is to make sure that the fire button is released before being pressed again

  on bullet_on goto no_bullet, bullet
bullet:
  if bullet_posy < 66 then
    bullet_on = 0
    poke SPR_CNTRL, peek(SPR_CNTRL) AND %11111101
    poke SID_CNTRL1, 64 'pulse, gate off
    goto no_bullet
  end if
  bullet_posy = bullet_posy - 4
  poke SPR_TE1_Y, bullet_posy
  SID_FREQ1 = shl(cword(bullet_posy), 4)
  poke SID_PULSE1, bullet_posy
no_bullet:
  joy_previous_fire = joy : joy = peek( $dc00)
  if (joy AND %00000100) = 0 then
    if ship_pos > 24 then ship_pos = ship_pos - 1
  else
    if (joy AND %00001000) = 0 then 
      if ship_pos < 320 then ship_pos = ship_pos + 1
    end if
  end if
  gosub move
  if (joy AND %00010000) = 0 AND (joy_previous_fire AND %00010000) then gosub fire
  exit sub
move:
  poke SPR_TE0_X, cbyte(ship_pos)
  if ship_pos > 255 then
    poke SPR_X_MSB, peek(SPR_X_MSB) OR  %00000001
  else
    poke SPR_X_MSB, peek(SPR_X_MSB) AND %11111110
  end if
  return
fire:
  if bullet_on then return
  bullet_on = 1
  bullet_posx = ship_pos + 11
  bullet_posy = 229
  poke SPR_TE1_X, cbyte(bullet_posx)
  poke SPR_TE1_Y, bullet_posy
  if bullet_posx > 255 then
    poke SPR_X_MSB, peek(SPR_X_MSB) OR %00000010
  else
    poke SPR_X_MSB, peek(SPR_X_MSB) AND %11111101
  end if
  poke SPR_CNTRL, peek(SPR_CNTRL) OR %00000010

  ' make sound
  SID_FREQ1 = 3760
  poke SID_PULSE1, 235
  poke SID_CNTRL1, 65 'Pulse, gate on
  return
end sub
