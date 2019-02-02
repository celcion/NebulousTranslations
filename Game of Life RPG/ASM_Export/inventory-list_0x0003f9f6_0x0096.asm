start: 0xF9E6
	LDA $05F8
	ASL
	TAY
	LDA $FAAF,Y
	STA $53
	LDA $FAB0,Y
	STA $54
	LDA #$40
	STA $51
	LDA #$04
	STA $52
	LDY #$00
_lbf9ff:
	LDA ($53),Y
	CMP #$FF
	BEQ _lbfa5c
	STA $04E8,Y
	ASL
	TAX
	LDA $FB04,X
	STA $4F
	LDA $FB05,X
	STA $50
	LDA $FBB1,X
	STA $4B
	LDA $FBB2,X
	STA $4C
	TYA
	PHA
	LDY #$00
_lbfa22:
	LDA ($4F),Y
	CMP #$FF
	BEQ _lbfa2e
	STA ($51),Y
	INY
	JMP _lbfa22
_lbfa2e:
	CLC
	LDA $51
	ADC #$08
	STA $4D
	LDA $52
	ADC #$00
	STA $4E
	JSR $CF9D
	LDY #$10
	LDA #$7F
	STA ($51),Y
	INY
	LDA #$FF
	STA ($51),Y
	CLC
	LDA $51
	ADC #$15
	STA $51
	LDA $52
	ADC #$00
	STA $52
	PLA
	TAY
	INY
	JMP _lbf9ff
_lbfa5c:
	STY $BC
	TYA
	TAX
	LDY #$00
_lbfa62:
	CPX #$08
	BEQ _lbfa7b
	LDA #$FF
	STA ($51),Y
	CLC
	LDA $51
	ADC #$15
	STA $51
	LDA $52
	ADC #$00
	STA $52
	INX
	JMP _lbfa62
_lbfa7b:
	RTS