shared const VIC_MEMSETUP = $D018
shared const SCREENMEM =    $0400
shared const COLOR =        $D800
shared const SPR_CNTRL =    $D015
shared const VIC2_CNTR2 =   $D016

'SPRITE is spelled SPR_TE because of a bug in XCB3.1 which doesn't allow an identifier made of a reserved word followed immediately by digits

shared const SPR_TE0_SHAPE = 2040 'player ship
shared const SPR_TE1_SHAPE = 2041 'player bullet
shared const SPR_TE2_SHAPE = 2042 'enemy bullet 1
shared const SPR_TE3_SHAPE = 2043 'enemy bullet 2
shared const SPR_TE4_SHAPE = 2044 'enemy bullet 3
shared const SPR_TE6_SHAPE = 2046 'ufo at the top

shared const SPR_TE0_X = $D000
shared const SPR_TE0_Y = $D001

shared const SPR_TE1_X = $D002
shared const SPR_TE1_Y = $D003

shared const SPR_TE2_X = $D004
shared const SPR_TE2_Y = $D005

shared const SPR_TE6_X = $D00C
shared const SPR_TE6_Y = $D00D

shared const SPR_TE1_COLOR = $D028
shared const SPR_TE6_COLOR = $D02D

shared const SPR_X_MSB    = $D010
shared const SPR_SPR_COLL = $D01E
shared const SPR_BG_COLL  = $D01F

Dim shared SID_FREQ1 as WORD @ $D400
Dim shared SID_FREQ2 as WORD @ $D407
dim shared SID_FREQ3 as WORD @ $D40E

shared const SID_PULSE1 = $D402

shared const SID_CNTRL1 = $D404
shared const SID_CNTRL2 = $D40B
shared const SID_CNTRL3 = $D412

shared const SID_AD1 = $D405
shared const SID_SR1 = $D406

shared const SID_AD2 = $D40C
shared const SID_SR2 = $D40D

shared const SID_AD3 = $D413
shared const SID_SR3 = $D414

shared const SID_VOLUME = $D418

dim shared enemy_map(60) as BYTE
dim shared enemy_bullet_on(3) as BYTE
dim shared enemy_bullet_posx(3) as WORD
dim shared enemy_bullet_posy(3) as BYTE

dim shared scroll as BYTE ': scroll = 0
dim shared enemy_posx as BYTE ': enemy_posx = 8
dim shared enemy_posy as BYTE ': enemy_posy = 0
dim shared bottom_row as BYTE ': bottom_row = 13
dim shared enemy_dir as BYTE ': enemy_dir = 1

dim shared ship_pos as WORD ': ship_pos = 176
dim shared bullet_on as BYTE ': bullet_on = 0
dim shared bullet_posx as WORD ': bullet_posx = 0
dim shared bullet_posy as BYTE ': bullet_posy = 0

dim shared last_killed_enemy as WORD ': last_killed_enemy = 0
dim shared score as WORD ': score = 0
dim shared addscore as BYTE ': addscore = 0
dim shared lives as BYTE ': lives = 3
dim shared level as BYTE ': level = 1
dim shared speed as BYTE ': speed = 20
dim shared game_speed as BYTE ': game_speed = 20

dim shared enemies_alive as BYTE ': enemies_alive = 60
dim shared scroll_bottom_limit as BYTE ': scroll_bottom_limit = 202
dim shared enemy_map_length as WORD ': enemy_map_length = 340

dim shared spos as WORD ': spos = 0

dim shared ufo_on as BYTE ': ufo_on = 0
dim shared ufo_pos as WORD ': ufo_pos = 370
dim shared ufo_hit as BYTE ': ufo_hit = 0
dim shared framecount_ufo as WORD ': framecount_ufo = 0

dim shared bottom_row_cached as BYTE
dim shared sound_phase as BYTE

'next 3 vars not originally declared in XCB2 version
Dim shared framecount as BYTE
Dim shared framecount_shooting as BYTE
Dim shared event as BYTE

dim shared notes(4) as WORD @loc_notes
loc_notes:
data as WORD 902, 955, 1012, 1072

'originally from invaders.bas
Dim shared map1(5) as BYTE @loc_map1
loc_map1:
DATA as BYTE 82,84,84,80,80

Dim shared bits(8) as BYTE @loc_bits
loc_bits:
DATA as BYTE 1, 2, 4, 8, 16, 32, 64, 128
