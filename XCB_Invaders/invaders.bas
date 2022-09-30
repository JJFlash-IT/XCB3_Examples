' -----------------------------------
' -- XCB Invaders
' -- written by Csaba Fekete
' --
' -- to be compiled using
' -- XC=BASIC v3.1
' -- 
' -- porting from XCB2, bug-fixing, optimizing & additional comments by @jjflash@mastodon.social
' -----------------------------------

' -- Global constants and variables

include "globals.bas"

' -- Go to program start

goto main

' -- Include all procedures

include "proc_init_charset.bas"
include "proc_init_sprites.bas"
include "proc_cls.bas"
include "proc_load_level.bas"
include "proc_draw_enemies.bas"
include "proc_draw_scene.bas"
include "proc_update_enemy_map_bottom.bas"
include "proc_ruin_shields.bas"
include "proc_shift_enemies.bas"
include "proc_move_enemies.bas"

' -- Include graphic charset at $2000

origin $2000
incbin "chars.bin"

' -- Include some more procedures

include "proc_move_ufo.bas"
include "proc_move_enemy_bullets.bas"
include "proc_enemy_shooting.bas"
include "proc_move_ship.bas"
include "proc_detect_collisions.bas"

' -- put all the rest
' -- above $4000 to make sure sprites
' -- and code don't overlap

origin $4000

include "proc_init_sound.bas"
include "proc_welcome_screen.bas"
include "proc_update_backup_ships.bas"
include "proc_reset_game.bas"
include "proc_lazy_routines.bas"


' -----------------------------------
' -- main program starts here
' -----------------------------------

main:
  call init_charset(0)
  call init_sprites()
  call init_sound()
  poke VIC_MEMSETUP, 24 'screen $0400, chars $2000
  border 0 : background 0
  poke $DC0D, $7F ' disables most interrupts...?

set:
  score = 0
  lives = 3
  level = 1
  game_speed = 20

  call welcome_screen()
  gosub wait_fire
  randomize (ti() )

level:
  call load_level()
  call draw_scene()
  enemies_alive = 60
  enemy_dir = 1
  bullet_on = 0
  bullet_posx = 0
  bullet_posy = 0
  last_killed_enemy = 0
  game_speed = game_speed - 1
  speed = game_speed
  enemy_map_length = 344
  ufo_pos = 370
  ufo_on = 0
  ufo_hit = 0
  framecount_ufo = 500
  bottom_row_cached = 4
  addscore = 0

  poke SPR_TE6_SHAPE, 246
  poke SPR_TE6_X, 0

game:
  call reset_game()
  
do 
  call move_ufo()
  '~ do : loop until cbyte(scan()) = 50
  do : loop until cbyte(scan()) = 58
  poke VIC2_CNTR2, scroll OR %11001000
  
  call move_enemy_bullets()
  
  do : loop until cbyte(scan()) = scroll_bottom_limit
  poke VIC2_CNTR2, %11001000 'scroll to 0
  
  framecount = framecount + 1
  framecount_shooting = framecount_shooting + 1

  if framecount < speed then
	call lazy_routines()
  else
	call move_enemies()
	  if enemy_posx = 12 and enemy_dir = 1 then
		call dshift_enemies()
		enemy_posy = enemy_posy + 1
		bottom_row = bottom_row + 1
		if bottom_row = 24 then goto game_over
		enemy_dir = 0
	  else
		if enemy_posx = 3 and enemy_dir = 0 then
		  call dshift_enemies()
		  enemy_posy = enemy_posy + 1
		  bottom_row = bottom_row + 1
		  if bottom_row = 23 then goto game_over
		  enemy_dir = 1
		end if
	  end if
   end if
  
  call detect_collisions(@event, @addscore)
  on event goto skip, live_lost, game_won
skip:
  call move_ship()
  if framecount_shooting >= enemies_alive then call enemy_shooting() : framecount_shooting = 0
loop

live_lost:
  score = score + addscore 'lazy_routines doesn't have any chance to run, out of the main loop

  poke SPR_CNTRL, 1 ' sprite 0 on, rest off

  poke SID_CNTRL1, 64 'voice 1, pulse gate off
  poke SID_CNTRL2, 32 'voice 2, sawtooth, gate off
  poke SID_CNTRL3, 129 'voice 3, noise waveform, on  

  for i as BYTE = 250 to 253
    poke SPR_TE0_SHAPE, i
    for j as BYTE = 0 to 12 'was 25, this loop is slower than using XCB2's WATCH
      do : loop until cbyte(scan()) = 0
    next j
  next i
  poke SID_CNTRL3, 128 'voice 3, noise waveform off
  
  lives = lives - 1
  if lives = 0 then goto game_over

  textat 4, 2, "ship down! press fire to continue"
  gosub wait_fire
  memset 1104, 40, 32 'clear message
  goto game

game_won:  
  score = score + addscore 'lazy_routines doesn't have any chance to run, out of the main loop
  
  poke SPR_CNTRL, 1 ' sprite 0 on, rest off
  
  poke SID_CNTRL2, 32 'voice 2, sawtooth, gate off
  poke SID_CNTRL3, 128 'voice 3, noise waveform off
  
  ' -- no more extra ships after 10
  if lives < 10 then
    lives = lives + 1
    textat 3, 2, "extra ship! press fire to continue"
  else
    textat 9, 2, "press fire to continue"
  end if
  gosub wait_fire
  memset 1104, 40, 32 'clear message

  level = level + 1
  textat 38, 0, level
  goto level

game_over:
  poke SID_CNTRL1, 64 'voice 1, pulse gate off
  poke SID_CNTRL2, 32 'voice 2, sawtooth, gate off
  poke SID_CNTRL3, 128 'voice 3, noise waveform off
  
  textat 2, 2, "game over - press fire to play again"
  gosub wait_fire
  poke SPR_CNTRL, 0 'welcome screen will appear again, so turn off all the sprites
  goto set

wait_fire:
    wait $DC00, 16 'wait for the button to be RELEASED, first
    wait $DC00, 16, 16
    return
