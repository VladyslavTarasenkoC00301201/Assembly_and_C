ORG	$1000
START:
	MOVE.B	#$64,D1
	LEA	text, A1
	MOVE	#14,D0
	TRAP	#15

	MOVE	#3,D0
	TRAP	#15

	SIMHALT

text dc.b 'Data Register: ',0

END START
