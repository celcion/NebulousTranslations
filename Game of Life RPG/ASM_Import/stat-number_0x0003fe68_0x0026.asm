start: 0xFE58
	LDA #$CE
	STA $4B
	LDA #$00
	STA $4C
	JSR $D200
	LDY #$00
_read:
	LDA ($4B),Y
	BEQ _skip
	STA $0160,X
	INX
_skip:
	INY
	CPY #$03
	BNE _read
	RTS