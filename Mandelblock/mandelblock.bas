' MandelBLOCK - a blocky Mandelbrot set
' inspired by Matt Hefferman's YT video "8-BIT battle royale" (https://www.youtube.com/watch?v=DC5wi6iv9io)
' code based on Wikipedia's Mandelbrot set pseudocode (https://en.wikipedia.org/wiki/Mandelbrot_set)
' with speed optimizations suggested by Csaba Fekete, creator of XC-Basic

' Ported to XC=BASIC v3.1 by @jjflash@mastodon.social

dim py as BYTE
dim px as BYTE
dim r as WORD
dim i as BYTE
dim xz as FLOAT
dim yz as FLOAT
dim x as FLOAT FAST
dim y as FLOAT FAST
dim xt as FLOAT FAST

BORDER 0
memset 1024, 1000, 160
SYSTEM INTERRUPT OFF

for py = 0 to 24
  yz = cfloat(py) * 2.0 / 24.0 - 1.0
  r = $D800 + py * cword(40)
  for px = 0 to 39
    xz = cfloat(px) * 3.5 / 40.0 - 2.5
    x = 0.0
    y = 0.0
    i = 0
    do while x * x + y * y <= 4 and i < 16
      xt = x * x - y * y + xz
      y = 2.0 * x * y + yz
      x = xt
      i = i + 1
    loop
    poke r + cword(px), i - 1
  next px
next py

SYSTEM INTERRUPT ON
poke 198, 0 : wait 198, 1 : poke 198, 0
