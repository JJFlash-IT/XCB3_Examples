' -----------------------------------
' -- move enemy bullets
' -----------------------------------

sub move_enemy_bullets() SHARED STATIC
  dim addr as WORD
  dim bit as BYTE
  for i as BYTE = 0 to 2
    if enemy_bullet_on(i) then
      enemy_bullet_posy(i) = enemy_bullet_posy(i) + 2
      if enemy_bullet_posy(i) < 236 then
        addr = SPR_TE2_Y + shl(i, 1)
        poke addr, enemy_bullet_posy(i)
      else
        enemy_bullet_on(i) = 0
        bit = bits(i + 2)
        poke SPR_CNTRL, peek(SPR_CNTRL) AND (bit XOR 255) 'turn off the sprite corresponding to the bullet turned off
      end if
    end if
  next i
end sub
