start: 0xAC43
	PLA
	ASL
	TAY
	LDA $ACCD,Y
	STA $53
	LDA $ACCE,Y
	STA $54
	LDA $05F8
	ASL
	TAY
	LDA ($53),Y
	STA $51
	INY
	LDA ($53),Y
	STA $52
	INY
	LDA $0740
	ASL
	TAY
	LDA ($51),Y
	STA $53
	INY
	LDA ($51),Y
	STA $54
	INY
	LDA #$40
	STA $51
	LDA #$04
	STA $52
	LDY #$00
_lbac78:
	LDA ($53),Y
	CMP #$FF
	BEQ _lbacad
	STA $04E8,Y
	ASL
	TAX
	LDA $AD83,X
	STA $4B
	LDA $AD84,X
	STA $4C
	TYA
	PHA
	JSR $FF81 ; _load_4b51
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
	JMP _lbac78
_lbacad:
	STY $BC
	TYA
	TAX
	LDY #$00
_lbacb3:
	CPX #$04
	BEQ _lbaccc
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
	JMP _lbacb3
_lbaccc:
	RTS