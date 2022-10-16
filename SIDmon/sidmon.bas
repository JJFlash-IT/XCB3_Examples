Const SID_MEM = $D400
Const COLOR_MEM = $D800
Const SCREEN_MEM = $0400

Dim bRegisterValues(25) as BYTE

Dim wOldColorLocation as WORD
Dim wNewColorLocation as WORD
Dim wCursorScreenLocation as WORD

declare sub moveCursor() STATIC

Dim sGotKey as STRING * 1

Dim sMessages(25) as STRING * 27 @loc_messages
loc_messages:
DATA AS STRING * 27 "freq control lo  {REV_ON}voice 1", "freq control hi"
DATA AS STRING * 27 "pulse width bits 7-0", "pulse width xxxx 11-8"
DATA AS STRING * 27 "n OL{165}N{165}NM tst ring syn gate"
DATA AS STRING * 27 "attack  decay", "sustain release"

DATA AS STRING * 27 "freq control lo  {REV_ON}voice 2", "freq control hi"
DATA AS STRING * 27 "pulse width bits 7-0", "pulse width xxxx 11-8"
DATA AS STRING * 27 "n OL{165}N{165}NM tst ring syn gate"
DATA AS STRING * 27 "attack  decay", "sustain release"

DATA AS STRING * 27 "freq control lo  {REV_ON}voice 3", "freq control hi"
DATA AS STRING * 27 "pulse width bits 7-0", "pulse width xxxx 11-8"
DATA AS STRING * 27 "n OL{165}N{165}NM tst ring syn gate"
DATA AS STRING * 27 "attack  decay", "sustain release"

DATA AS STRING * 27 "xxxxx fc2-fc0  {REV_ON}filter", "filter bits fc10-fc3"
DATA AS STRING * 27 "resonance fx f3 f2 f1", "v3off hp bp lp vol3-vol0"

for x as BYTE = 0 to 23
	bRegisterValues(x) = 0
	poke SID_MEM + x , 0
next x

'voice 1
bRegisterValues(1)  = 32  '00100000
bRegisterValues(4)  = 32  '00100000
bRegisterValues(6)  = 136 '10001000

'voice 2
bRegisterValues(8)  = 32  '00100000
bRegisterValues(11) = 16  '00010000
bRegisterValues(13) = 136 '10001000

'voice 3
bRegisterValues(15) = 32  '00100000
bRegisterValues(18) = 128 '10000000
bRegisterValues(20) = 136 '10001000

bRegisterValues(24) = 15  '00001111

print "{CLR}{WHITE}";
for y as BYTE = 0 to 24
	for x = 0 TO 7
		print chr$(49 + ((bRegisterValues(y) AND shl(1, 7 - x)) = 0) );
	next x
	print " " + str$(y) + " " + sMessages(y) ;
	poke SID_MEM + y, bRegisterValues(y)
	if y < 24 then print ""
next y

x = 0 : y = 0
wOldColorLocation = COLOR_MEM
call moveCursor()

poke $028A, $80 'keyboard repeat for all keys

do
	poke 198, 0 : wait 198, 1 : get sGotKey
	
	if sGotKey = "1" then
		bRegisterValues(4) = ( bRegisterValues(4) XOR 1 )
		poke 1191, peek(1191) XOR 1
		poke SID_MEM + 4, bRegisterValues(4)
		continue do
	end if
	if sGotKey = "2" then
		bRegisterValues(11) = ( bRegisterValues(11) XOR 1 )
		poke 1471, peek(1471) XOR 1
		poke SID_MEM + 11, bRegisterValues(11)
		continue do
	end if
	if sGotKey = "3" then
		bRegisterValues(18) = ( bRegisterValues(18) XOR 1 )
		poke 1751, peek(1751) XOR 1
		poke SID_MEM + 18, bRegisterValues(18)
		continue do
	end if
	if sGotKey = "{CRSR_RIGHT}" then
		x = (x + 1) AND 7
		call moveCursor()
		continue do
	end if
	if sGotKey = "{CRSR_LEFT}" then
		x = (x - 1) AND 7
		call moveCursor()
		continue do
	end if
	if sGotKey = "{CRSR_DOWN}" then
		y = y + 1 : if y = 25 then y = 0
		call moveCursor()
		continue do
	end if
	if sGotKey = "{CRSR_UP}" then
		y = y - 1 : if y = 255 then y = 24
		call moveCursor()
		continue do
	end if
	if sGotKey = " " then
		wCursorScreenLocation = SCREEN_MEM + x + cword(y) * 40
		bRegisterValues(y) = ( bRegisterValues(y) XOR shl(1, 7 - x) )
		poke wCursorScreenLocation, peek(wCursorScreenLocation) XOR 1

		poke SID_MEM + y, bRegisterValues(y)
	end if
loop

sub moveCursor() STATIC
	wNewColorLocation = COLOR_MEM + x + cword(y) * 40
	poke wOldColorLocation, 1 'white
	poke wNewColorLocation, 4 'purple
	wOldColorLocation = wNewColorLocation
end sub

 
