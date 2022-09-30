' -----------------------------------
' -- test for sprite collisions
' -----------------------------------

sub detect_collisions(result_ptr as WORD, score_ptr as WORD) SHARED STATIC
  Dim coll_state as BYTE : coll_state = peek(SPR_BG_COLL)
  Dim spr_coll_state as BYTE : spr_coll_state = peek(SPR_SPR_COLL)
  Dim col as BYTE
  Dim row as BYTE
  Dim hit_position as WORD
  Dim char as BYTE
  Dim bullet_no as BYTE
  
  if (coll_state AND %00000010) = 2 then gosub enemy_hit
  if (coll_state AND %00011100) then gosub shield_hit_by_enemy
  if spr_coll_state then gosub ship_hit
  exit sub

  'this section has been rewritten almost from scratch
  enemy_hit:
    if bullet_posy > scroll_bottom_limit then
		col = cbyte(shr(bullet_posx, 3)) - 3 '24 sprite pixel horizontal offset / 8 = 3...
    else
		col = cbyte(shr(bullet_posx - cword(scroll), 3)) - 3 '24 sprite pixel horizontal offset / 8 = 3...
    end if
    row = shr(bullet_posy - 50, 3)
    hit_position = SCREENMEM + cword(col) + 40 * cword(row)

    char = peek(hit_position)
    
    'couldn't use Select Case as it's unstable at the time of writing!
    if char >= 88 and char <= 90 then 'intact shield
		poke hit_position, char + 3 'it becomes damaged
    else
		if char >= 91 and char <= 93 then 'damaged shield
			poke hit_position, 32 'it disappears completely
		else
			if char >= 80 and char <= 85 then 'invaders chars
				enemy_map((row - enemy_posy - 5) * 6 + shr(col - enemy_posx, 1)) = 255
				last_killed_enemy = hit_position
				if (char AND 1) then
					last_killed_enemy = last_killed_enemy - 1
					col = col - 1
					char = char - 1
				end if
				'the invader becomes an explosion
				charat col, row, 86
				charat col + 1, row, 87
				
				if char = 82 then '3-point invader
					poke score_ptr, 3
				else
					if char = 84 then '2-point invader
						poke score_ptr, 2
					else
						if char = 80 then '1-point invader
							poke score_ptr, 1 
						end if
					end if
				end if
				
				poke SID_CNTRL3, 129 'noise, gate on
				enemies_alive = enemies_alive - 1
				if enemies_alive = 0 then poke result_ptr, 2
				speed = shr(enemies_alive, 2) + 5
				
			else
				return
			end if
		end if
    end if
    
    bullet_on = 0
    poke SID_CNTRL1, 64 'voice 1, gate off
    poke SPR_CNTRL, peek(SPR_CNTRL) AND %11111101 'turn off player bullet sprite
    return

  shield_hit_by_enemy:
    ' -- can be multiple bullets
    
    for bn as BYTE = 2 to 4
      if (coll_state AND bits(bn)) then
        bullet_no = bn - 2 
        col = cbyte(shr(enemy_bullet_posx(bullet_no), 3)) - 3
        row = shr(enemy_bullet_posy(bullet_no) - 49, 3)
        hit_position = SCREENMEM + cword(col) + 40 * cword(row)
        char = peek(hit_position)
        'if the shield is intact, break it partially. Otherwise, erase it completely
        if char >= 88 then 
          if char < 91 then
            poke hit_position, char + 3
          else
            poke hit_position, 32
          end if
        else
          return 'the bullet hit an invader "explosion" or other garbage...
        end if
        enemy_bullet_on(bullet_no) = 0
        poke SPR_CNTRL, peek(SPR_CNTRL) AND (bits(bn) XOR $ff)
      end if
    next bn
    return

  ship_hit:
    ' player ship hit
    if (spr_coll_state AND %00000001) then 
      poke result_ptr, 1
      return
    end if
    ' ufo hit
    if (spr_coll_state AND %01000000) then
      bullet_on = 0
      poke SID_CNTRL1, 64 'pulse, gate off
      poke SPR_CNTRL, peek(SPR_CNTRL) AND %11111101 'turn off player bullet sprite
      ufo_hit = 1
      poke score_ptr, 30
      poke SPR_TE6_SHAPE, 247 ' ufo shape - change to "30"
      return
    end if
end sub
