'
' galenciastars.bas
'
' By Alan Bourke in 2021 using XC-BASIC 2.3
'
' This is a conversion of Jason Aldred's Galencia starfield, taken from his
' game of the same name. Jason extracted the starfield ASM code into a standalone
' programme (see link below), and this is an XC-BASIC recreation of that.
' 
' I wanted to see if an XC-BASIC version could approach the speed of the ASM and 
' in an eyeball test at least, it does. I've commented the code quite heavily to 
' maybe help other people in tasks like redefining the char set and so on.
'
' I briefly worked in the same dev house as Jason in the early 90s, and he was
' always ready to help other coders. I know he's had his health problems so if he 
' ever reads this, I hope he's OK.
'
' Useful Links
'
' Jason Aldred's original Galencia starfield extracted to a standalone program.
' https://github.com/Jimmy2x2x/C64-Starfield/blob/master/starfield.asm
'
' Info about the C64 character set.
' https://github.com/neilsf/XC-BASIC/tree/master/examples/invaders
' https://www.c64-wiki.com/wiki/Character_set
'
' Info about the C64 memory map.
' https://www.pagetable.com/c64ref/c64mem/
' https://github.com/Project-64/reloaded/blob/master/c64/mapc64/MAPC6412.TXT
'
' GRay Defender's breakdown of how the original ASM works - WATCH THIS.
' https://www.youtube.com/watch?v=47LakVkR5lg
'
' -- Ported to XCB 3.1 by @jjflash@mastodon.social


' Star shapes
const Star1Shape    = %00000011  ' 3
const Star2Shape    = %00001100  ' 12
const Star3Shape    = %00110000  ' 48
const Star4Shape    = %11000000  ' 192

const SCREENMEM     = $0400
const COLOUR        = $D800
const CHAR_ROM      = $D000
const CHAR_RAM      = $3000
const NUMCHARS      = $0800 ' 256 chars x 8 bytes each 

'const VIC_CTRL      = $D018
const CPU_IO        = $0001
const SCRN_CTRL     = $D011

const Star1Init     = $31D0 ' Init address for each star, CHAR_RAM plus offset
const Star1Limit    = $3298 ' Limit for each star
const Star1Reset    = $31d0 ' Reset address for each star

const Star2Init     = $3298
const Star2Limit    = $3360 ' Once limit is reached, they are reset
const Star2Reset    = $3298

const Star3Init     = $3240
const Star3Limit    = $3298
const Star3Reset    = $31d0

const Star4Init     = $32E0
const Star4Limit    = $3360
const Star4Reset    = $3298

const StaticStar1   = $3250 ' 2 Locations for blinking static stars
const StaticStar2   = $31e0

dim RasterCount as BYTE    fast 
dim StarfieldPtr as WORD   fast
dim StarfieldPtr2 as WORD  fast
dim StarfieldPtr3 as WORD  fast
dim StarfieldPtr4 as WORD  fast 
dim TempWork as BYTE       fast

Dim StarfieldRow(40) as BYTE @mem_StarfieldRow
Dim StarfieldColours(20) as BYTE @mem_StarfieldColours


' ------------------------------------------------------------------------------------------------------------------------------------
' This routine copies the C64 character set from ROM into RAM, allowing it to then be redefined..
' ------------------------------------------------------------------------------------------------------------------------------------
sub CopyCharsetToRam() STATIC
  
    system interrupt off                                    ' Turn off interrupts from the keyboard etc.

    poke CPU_IO, (peek(CPU_IO) AND %11111010)               ' The '0' in bit 2 tells the CPU to stop looking at I\O
                                                            ' and to start looking at the character set in ROM so that it can be read.

    memcpy CHAR_ROM, CHAR_RAM, NUMCHARS                     ' Copy the 2KB ROM character set to RAM starting at location $3000.

    poke CPU_IO, (peek(CPU_IO) OR %0100)                    ' Switch I\O back in instead of character set in ROM.

    CHARSET 6                                               ' Tell the VIC-II to from now on look at location $3000 for the character set. 
                                                            ' This is controlled by bits 1, 2 and 3 of location $D018 (VIC_CTRL)
                                                            ' counting from right to left. Those three bits represent a number which
                                                            ' when multiplied by 2048 gives the memory location where the character set 
                                                            ' starts.
   'poke VIC_CTRL, (peek(VIC_CTRL) AND %11110000) OR %1100  ' Looking at the 'poke' above, we are ORing with the binary value 1100
                                                            ' Ignoring the rightmost bit, we have 110 = decimal 6, so 6 x 2048 = 12288 
                                                            ' which in hex is the location $3000 where our copy of the character set is.

    system interrupt on                                     ' Interrupts back on.

    'memset CHAR_RAM, 2048, 0                                ' Clear user defined character set.
                                                            ' Comment this line out to see the result of the CreateStarScreen 
                                                            ' routine below.

end sub

' ------------------------------------------------------------------------------------------------------------------------------------
' Initial screen setup.
' 
' This routine draws columns of characters onto the C64 text screen. 
' ------------------------------------------------------------------------------------------------------------------------------------
sub CreateStarScreen() STATIC
    Dim char as BYTE
    Dim colourindex as BYTE : colourindex = 0
    Dim offset as WORD
  
    poke SCRN_CTRL, peek(SCRN_CTRL) AND %11101111           ' Turn the screen off for speed and tidiness.

    For col as BYTE = 0 to 39                               ' C64 character text screen has 40 columns.

        char = StarfieldRow(col)                            ' Get the next character number from the StarfieldRow array. The first one is character 58 
                                                            ' which is a ':'.
		offset = col

        For row as BYTE = 0 to 24                           ' C64 character text screen has 25 rows.

                                                            ' The text screen can be though of as a grid. however in memory 
                                                            ' it starts at location $0400 and is comprised of 1000 memory locations.
                                                            ' Given a row and column this calculation gives the offset from the start of screen memory 
                                                            ' to the location we want.
                                                            ' EDIT: here originally was the line " offset = (col! + (row * 40)) ". By eliminating
                                                            ' the multiplication, the whole operation is noticeably faster

            poke SCREENMEM + offset, char                   ' Stick the current character onto the screen at the current row and column.

            char = char + 1                                 ' Point at the next char in the array.

            if char = 83 then
                char = 58                                   ' If we've gone past character 82 then start again.
            end if

            if char = 108 then
                char = 83                                   ' If we've gone past character 107 then back to 83.
            end if  

            poke COLOUR + offset, _
                StarfieldColours(colourindex)               ' The colours of the C64 character screen are defined by the 1000 locations from $D800
                                                            ' onwards, each location corresponding to a location on the character screen at $0400
                                                            ' So we put the current colour from the colour array into the colour location corresponding
                                                            ' to the current row and column on the text screen.

			offset = offset + 40                            'next row!
        Next row

        colourindex = colourindex + 1                       ' Next column, next colour.

        if colourindex > 19 then colourindex = 0

    Next col

    poke SCRN_CTRL, peek(SCRN_CTRL) OR %00010000            ' Turn the screen back on.
  
	'poke 198,0: wait 198, 1                                 ' If uncommented this waits for a keypress.
	
end sub

declare sub DoStarfield() STATIC

' ------------------------------------------------------------------------------------------------------------------------------------
' Main routine.
' ------------------------------------------------------------------------------------------------------------------------------------
    BORDER 0                                                ' Black screen background and border.
    BACKGROUND 0
  
    call CopyCharsetToRam()                                 ' Copy the ROM character set to RAM.

    call CreateStarScreen()                                 ' Set up the initial screen.

    
    RasterCount     = 1
    
    StarfieldPtr    = Star1Init
    StarfieldPtr2   = Star2Init
    StarfieldPtr3   = Star3Init
    StarfieldPtr4   = Star4Init

do

    do : loop until cbyte(scan()) = 255                     ' Wait for raster to be offscreen. We do our drawing at that point 
                                                            ' to avoid flicker. 
                                                            
  
    RasterCount = RasterCount + 1                           ' A counter controlling which group of stars is redrawn, i.e. 
                                                            ' this implements the different star speeds. Will automatically wrap 255 to 0 

    call DoStarfield()                                      ' Draw the stars.

loop

sub DoStarfield() STATIC
  
    ' Star 1 -----------------------------------------------
    if (RasterCount AND 1) then                             ' Star 1 updates every other frame.
    poke StarfieldPtr, 0                                ' Clear any existing stars by zeroing their memory location
        StarfieldPtr = StarfieldPtr + 1                     
        if StarfieldPtr = Star1Limit then StarfieldPtr = Star1Reset
    end if
    poke StarfieldPtr, peek(StarfieldPtr) OR Star1Shape

    ' Star 2 -----------------------------------------------
    poke StarfieldPtr2, 0                                   ' Clear any existing stars by zeroing their memory location
    StarfieldPtr2 = StarfieldPtr2 + 1                       ' Star 2 updates every frame.
    poke StarfieldPtr2, peek(StarfieldPtr2) OR Star2Shape
    if StarfieldPtr2 = Star2Limit then StarfieldPtr2 = Star2Reset

    ' Star 3 -----------------------------------------------
    if (RasterCount AND 1) then                             ' Star 3 updates every other frame.
        poke StarfieldPtr3, 0                               ' Clear any existing stars by zeroing their memory location
        StarfieldPtr3 = StarfieldPtr3 + 1
        if StarfieldPtr3 = Star3Limit then StarfieldPtr3 = Star3Reset
    end if
    poke StarfieldPtr3, peek(StarfieldPtr3) OR Star3Shape

    ' Star 4 -----------------------------------------------
    poke StarfieldPtr4, 0                                   ' Clear any existing stars by zeroing their memory location
    StarfieldPtr4 = StarfieldPtr4 + 2                       ' Star 4 updates 2 pixels every frame.
    poke StarfieldPtr4, peek(StarfieldPtr4) OR Star4Shape       
    if StarfieldPtr4 = Star4Limit then StarfieldPtr4 = Star4Reset

    ' Static stars -----------------------------------------
    if RasterCount < 230 then                                 
        poke StaticStar1, peek(StaticStar1) OR Star4Shape   ' Uses same shape as Star 4.       
    else
        poke StaticStar1, 0
    end if
    
    TempWork = RasterCount XOR $80                          ' Flip most significant bit. So TempWork will
                                                            ' cycle between decimal 128 and 0.

    if TempWork < 230 then
        poke StaticStar2, peek(StaticStar2) OR Star4Shape
    else
        poke StaticStar2, 0
    end if

end sub
' ------------------------------------------------------------------------------------------------------------------------------------
' Data declarations.
' ------------------------------------------------------------------------------------------------------------------------------------ 
' These are character indexes, not screen codes.
' 058 is a ':', 077 is a '\' 
mem_StarfieldRow:
DATA AS BYTE 058,092,073,064,091,062,093,081,066,094, _
             086,059,079,087,080,071,076,067,082,095, _
             100,078,099,060,075,063,084,065,083,096, _
             068,088,074,061,090,098,085,101,097,077

mem_StarfieldColours:
DATA AS BYTE 14,10,12,15,14,13,12,11,10,14, _
             14,10,14,15,14,13,12,11,10,12
