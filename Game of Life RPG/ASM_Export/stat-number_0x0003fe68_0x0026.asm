start: 0xFE58
	LDA #$01
	JSR _lbfe64
	RTS
	LDA #$00
	JSR _lbfe64
	RTS
_lbfe64:
	PHA
	LDA #$CE
	STA $4B
	LDA #$00
	STA $4C
	JSR $D200
	PLA
	TAY
_lbfe72:
	LDA ($4B),Y
	STA $0160,X
	INX
	INY
	CPY #$03
	BNE _lbfe72
	RTS