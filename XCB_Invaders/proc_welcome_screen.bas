' -----------------------------------
' -- welcome screen
' -----------------------------------

sub welcome_screen() SHARED STATIC
  call cls()
  textat 15, 2, "welcome to"
  textat 10, 4, "*** xcb invaders ***"
  textat 11, 6, "press fire to play"
  
  textat 14, 10, "{96}A = 1 point"
  textat 14, 12, "BC = 2 points"
  textat 14, 14, "DE = 3 points"
  textat 14, 16, "NO = 30 points"

  
  textat 11, 24, "visit xc-basic.net"
end sub
