' -----------------------------------
' -- detect the bottom of enemy map
' -----------------------------------

sub update_enemy_map_bottom() SHARED STATIC
  Dim row as BYTE
  Dim row_empty as BYTE
  Dim col as BYTE
  Dim row_offset as BYTE

    row = bottom_row_cached
	if bottom_row_cached > 0 then 'if enemy_map has bogus data, row can become 255 and then ALL HELL BREAKS LOOSE !
	  do
		row_empty = 1
		col = 11
		row_offset = row * 12
		do
		  if enemy_map(col + row_offset) <> 255 then row_empty = 0 : exit do
		  col = col - 1
		loop until col = 0
		if row_empty = 0 then exit do
		row = row - 1
	  loop until row = 0
	  bottom_row_cached = row
	end if
  
  bottom_row = 5 + enemy_posy + shl(row, 1)
  enemy_map_length = cword(shl(row, 1)) * 40 + cword(25)

end sub
