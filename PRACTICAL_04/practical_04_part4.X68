	ORG	$1000
START:
	LEA	HEALTH, A3


LOOP:


QUESTIONER:


GET_TIME:
	; writing system call number used to get date and time to the stack
	MOVE.W	#11, -(sp)
	TRAP	#15

	; the system call writes the year month day time to seconds in the data registers D1-D3

	; after the operation we are restoring the stack to the origingal state
	addq.l	#2, sp
	
	; store the hours minutes and seconds to the heap variable
	MOVE.W	D3, HOUR_MIN_SEC

HEATH_MODIFIER:
; D4, A3
	





HEALTH	dc.b	#$64
	
HOUR_MIN_SEC	dc.w	0


