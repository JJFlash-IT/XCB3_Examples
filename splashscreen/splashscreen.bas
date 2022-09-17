' ----------------------------------------------
' -- splash screen
' -- written by Eric Hilaire aka Majikeyric
' --
' -- to be compiled using
' -- XC=BASIC 3.1 -- ported from XCB2 & optimized by @jjflash@mastodon.social
' ----------------------------------------------

'reimplementation of XCB2's Deek function
function deek as WORD (wAddress as WORD) STATIC
	return cword(peek(wAddress)) OR shl(cword(peek(wAddress + 1)), 8)
end function

Dim screen_1 as WORD
Dim colors as WORD
Dim bitmap as WORD
Dim screen_2 as WORD
Dim chargen as WORD

Dim backcol as BYTE
Dim i as BYTE
Dim j as BYTE

Dim Width as BYTE
Dim height as BYTE
Dim nbcars as WORD
Dim offset_colors as WORD
Dim offset_bitmap as WORD
Dim modulo_colors as WORD
Dim modulo_bitmap as WORD
Dim bin as WORD

Const HEADER_SIZE = 12

screen_2    = $4c00
screen_1    = $0400
colors      = $d800
bitmap      = $6000
bin         = @splash_bin

' --- Get splash screen params from binary header

width           = peek(bin)
height          = peek(bin +  1)
nbcars          = deek(bin +  2)
offset_colors   = deek(bin +  4)
offset_bitmap   = deek(bin +  6)
modulo_colors   = deek(bin +  8)
modulo_bitmap   = deek(bin + 10)
   
backcol = peek( $d021) AND $0f

asm
	sei
end asm

' --- Convert actual screen to bitmap hires

do
	poke screen_2, shl(peek(colors), 4) OR backcol
	colors = colors + 1
	screen_2 = screen_2 + 1

	chargen = $d000 + shl(cword(peek(screen_1)), 3)

	poke $01, $32
	memcpy chargen, bitmap, 8
	bitmap = bitmap + 8
	poke $01, $36

	screen_1 = screen_1 + 1
loop until screen_1 = $07e8

' --- Build splash screen on bitmap

screen_1  = $4c00 + offset_colors
screen_2  = $6000 + offset_bitmap
colors    = bin + HEADER_SIZE
bitmap    = bin + HEADER_SIZE + nbcars

j = shl(width, 3) ' width * 8
for i = 0 to height - 1
	memcpy colors, screen_1, width
	colors = colors + width
	screen_1 = screen_1 + width + modulo_colors

	memcpy bitmap, screen_2, j
	screen_2 = screen_2 + j + modulo_bitmap
	bitmap = bitmap + j
next i
   
' --- Display hires bitmap and loop

wait $d011, $80, $80 : wait $d011, $80 ' --- Wait for VBL

poke $dd00, 2   '0000 0010 -- bank 1 selected : $4000-$7FFF
poke $d011, $3b '0011 1011 -- switch Bitmap mode on (bit 5)
poke $d018, $38 '0011 1000 -- Matrix: $4C00 ($0C00 + bank offset), bitmap: $6000 ($2000 + bank offset)

do : loop

splash_bin:
incbin "arcia.bin" 
