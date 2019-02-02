start: 0xFE7E
	LDA $D1
	JSR $F6DA
	LDY #$02
_lbfe85:
	LDA ($4B),Y
	CMP #$FF
	BEQ _lbfe93
	STA $0160,X
	INX
	INY
	JMP _lbfe85
_lbfe93:
	RTS