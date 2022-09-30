' -----------------------------------
' -- ruin all shields when enemies
' -- get there
' -----------------------------------

sub ruin_shields() SHARED STATIC
  memset 1790, 109, 32 'originally memset 1824, 120, 32 , didn't erase shields correctly
  scroll_bottom_limit = 241 'originally 250, too much, it scrolled everything!
end sub
