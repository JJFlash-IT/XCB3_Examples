' -----------------------------------
' -- initialize charset
' -----------------------------------

sub init_charset(animphase as BYTE) SHARED STATIC
	on animphase goto init_1, init_2
	exit sub

init_1:
	memcpy $2200, $2280, 16
	memcpy $2220, $2290, 16
	memcpy $2240, $22A0, 16
	exit sub

init_2:
	memcpy $2210, $2280, 16
	memcpy $2230, $2290, 16
	memcpy $2250, $22A0, 16
	exit sub
end sub
