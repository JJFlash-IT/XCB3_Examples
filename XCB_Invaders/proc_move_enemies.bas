' -----------------------------------
' -- move enemy map
' -----------------------------------

sub move_enemies() SHARED STATIC
  poke SID_CNTRL2, 32 'sawtooth, gate off
  poke SID_CNTRL2, 33 'sawtooth, gate on
  SID_FREQ2 = notes(sound_phase)
  sound_phase = (sound_phase - 1) AND 3
 
  if last_killed_enemy <> 0 then
    poke last_killed_enemy, $20
    poke last_killed_enemy + 1, $20
    poke SID_CNTRL3, 128 'noise, gate off
    last_killed_enemy = 0
  end if
  on enemy_dir goto move_left, move_right
  
move_right:
    scroll = scroll + 1
    if scroll = 8 then
      scroll = 0
      enemy_posx = enemy_posx + 1
      call rshift_enemies()
    end if
    call init_charset(scroll AND 1)
    framecount = 0
    exit sub

move_left:
    scroll = scroll - 1
    if scroll = 255 then
      scroll = 7
      enemy_posx = enemy_posx - 1
      call lshift_enemies()
    end if
    call init_charset(scroll AND 1)
    framecount = 0
    exit sub
end sub
