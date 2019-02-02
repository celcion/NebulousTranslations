start: 0xFD4D
	LDX #$00
	LDY #$00
_lbfd51:
	LDA $06C0,Y
	CMP #$FF
	BEQ _lbfd70
	CMP #$FD
	BEQ _lbfd64
	STA $0160,X
	INX
	INY
	JMP _lbfd51
_lbfd64:
	TYA
	PHA
	JSR _lbfd74
	PLA
	TAY
	INY
	INY
	JMP _lbfd51
_lbfd70:
	STA $0160,X
	RTS
_lbfd74:
	INY
	LDA $06C0,Y
	ASL
	TAY
	LDA $FD87,Y
	STA $49
	LDA $FD88,Y
	STA $4A
	JMP ($0049)