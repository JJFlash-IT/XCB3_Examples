sub init_sound() SHARED STATIC
  poke SID_VOLUME, 15

  'voice 1 is for the player bullet sound
  poke SID_AD1, %00010100
  poke SID_SR1, %00100000

  'voice 2 is for the invaders' 4-notes sound
  poke SID_AD2, %01110100
  poke SID_SR2, %00010000
  
  'voice 3 is for explosions
  poke SID_AD3, %00010100
  poke SID_SR3, %00010110

  SID_FREQ3 = 440 'never changes its frequency
end sub
