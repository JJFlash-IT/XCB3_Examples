' -----------------------------------
' -- clear the screen
' -----------------------------------

sub cls() SHARED STATIC
  memset SCREENMEM, 1000, 32
  memset COLOR, 40, 13 'Light Green
  memset COLOR + 80, 40, 10 'Light Red
  memset COLOR + 200, 80, 7 'Yellow
  memset COLOR + 280, 80, 8 'Orange
  memset COLOR + 360, 80, 10 'Light Red
  memset COLOR + 440, 80, 13 'Light Green
  memset COLOR + 520, 80, 14 'Light Blue
  memset COLOR + 600, 400, 6 'Blue 
  memset COLOR + 760, 240, 12 'Grey
end sub
