sub update_backup_ships() SHARED STATIC
ship_shape:
data as BYTE 109, 110, 111

  memset 1984, 40, 90
  
  for i as BYTE = 0 to lives - 1
    memcpy @ship_shape, 1984 + i * 3, 3
  next i

end sub
