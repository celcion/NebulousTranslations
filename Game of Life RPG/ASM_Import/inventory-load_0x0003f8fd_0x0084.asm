start: 0xF8ED
	LDA #$40
	STA $4F
	LDA #$04
	STA $50
	LDA $075A
	STA $55
	LDX #$00
_lbf8fc:
	CPX $55
	BEQ _lbf949
	LDY #$00
	LDA $075B,X
	PHA
	BMI _lbf90a
	LDY #$02
_lbf90a:
	LDA $F971,Y
	STA $4B
	LDA $F972,Y
	STA $4C
	PLA
	STA $04E8,X
	ASL
	TAY
	LDA ($4B),Y
	STA $4D
	INY
	LDA ($4B),Y
	STA $4E
	JSR $FF70 ; _load_4d4f
	LDY #$08
	LDA #$FF
	STA ($4F),Y
	CLC
	LDA $4F
	ADC #$15
	STA $4F
	LDA $50
	ADC #$00
	STA $50
	INX
	JMP _lbf8fc
_lbf949:
	STX $BC
	LDY #$08
_lbf94d:
	CPX #$08
	BEQ _lbf966
	LDA #$FF
	STA ($4F),Y
	CLC
	LDA $4F
	ADC #$15
	STA $4F
	LDA $50
	ADC #$00
	STA $50
	INX
	JMP _lbf94d
_lbf966:
	LDA $BC
	BNE _lbf96e
	LDA #$84
	STA $C9
_lbf96e:
	PLA
	TAX
	RTS