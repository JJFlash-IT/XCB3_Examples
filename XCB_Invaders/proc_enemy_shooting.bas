' -----------------------------------
' - make enemies shoot if
' - there is a free slot for
' - the new bullet
' -----------------------------------

sub enemy_shooting() SHARED STATIC
  Dim col as BYTE
  Dim row as BYTE
  Dim addr as WORD
  Dim bit as BYTE

  for i as BYTE = 0 to 2
    if enemy_bullet_on(i) = 0 then goto shoot
  next i
  exit sub
  
shoot:
  ' -- find out which enemy shoots
  ' -- i! now holds the slot number
  col = rndb() AND %00001111
  if col > 11 then exit sub
  row = 4
  do
    if enemy_map(row * 12 + col) <> 255 then
      ' -- now shoot
      enemy_bullet_on(i) = 1
      enemy_bullet_posx(i) = cword(shl(col, 1) + enemy_posx) * 8 + 32
      enemy_bullet_posy(i) = (shl(row, 1) + enemy_posy) * 8 + 101
      addr = SPR_TE2_X + shl(i, 1) 'Sprite 2+i X address
      poke addr, cbyte(enemy_bullet_posx(i))
      addr = addr + 1 'Sprite 2+i Y address
      poke addr, enemy_bullet_posy(i)
      bit = bits(i + 2)
      if enemy_bullet_posx(i) > 255 then 'originally was "if bullet_posx > 255 then", so enemy bullets often came out of nowhere  :)
        poke SPR_X_MSB, peek(SPR_X_MSB) OR bit
      else
        poke SPR_X_MSB, peek(SPR_X_MSB) AND (bit XOR 255) 
      end if
      poke SPR_CNTRL, peek(SPR_CNTRL) OR bit
      exit sub
    end if
    row = row - 1
  loop until row = 255
end sub
