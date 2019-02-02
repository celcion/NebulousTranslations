start: 0xFE96
	JSR $F9BF
	LDY #$00
_lbfe9b:
	LDA ($4B),Y
	CMP #$FF
	BEQ _lbfea9
	STA $0160,X
	INX
	INY
	JMP _lbfe9b
_lbfea9:
	RTS