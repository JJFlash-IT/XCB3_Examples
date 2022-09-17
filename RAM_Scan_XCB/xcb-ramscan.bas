'
' HEAVILY inspired by RAM Scan 64's video by Robin Harbron -- https://www.youtube.com/watch?v=6g0Cev-3D2g&t=1276s
'

Const CRSR_DN = 65152
Const CRSR_RT = 65028
Const LSHIFT =  64896
Const RSHIFT =  48912

Dim wSourceAddress as WORD : wSourceAddress = 0

poke $d018, $17 'changes to lowercase
poke 646, 1 'foreground, white
sys $E544 FAST 'clear screen

do
	memcpy wSourceAddress, 1024, 960
	textat 0, 24, str$(wSourceAddress) + "    "

	if key(LSHIFT) or key(RSHIFT) then
		if key(CRSR_DN) then 'it's actually UP
			wSourceAddress = wSourceAddress - 80
		else
			if key(CRSR_RT) then 'it's actually LEFT
				wSourceAddress = wSourceAddress - 1
			end if
		end if
	else
		if key(CRSR_DN) then
			wSourceAddress = wSourceAddress + 80
		else
			if key(CRSR_RT) then
				wSourceAddress = wSourceAddress + 1
			end if
		end if
	end if
loop
