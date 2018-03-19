start: 0xB287
_lbb287:
	AND #$0F
	STY $03
	TAY
_lbb28c:
	LDA $B27B,Y
	STA $0700,X
	INX
	INY
	CPY #$0C
	BCC _lbb28c
	LDY $03
	INY
	RTS
_lbb29c:
	LDA #$3F
	INY
	JSR _lbb32c
	LDA #$00
	JSR _lbb32c
_lbb2a7:
	LDA ($00),Y
	CMP #$FE
	BEQ _lbb312
	CMP #$80
	BCC _lbb2b4
	JSR _lbb287
_lbb2b4:
	LDA #$0F
	STA $0700,X
	INX
	LDA #$02
	STA $03
_lbb2be:
	LDA ($00),Y
	STA $0700,X
	INX
	INY
	DEC $03
	BPL _lbb2be
	BMI _lbb2a7
	PHA
	LDA #$02
	STA $03
	LDA #$01
	JSR _lbb32c
	PLA
	STA $02
	ASL
	TAX
	LDA $B348,X
	STA $00
	LDA $B349,X
	STA $01
	LDX $E7
	LDY #$00
	LDA ($00),Y
	CMP #$FE
	BEQ _lbb29c
_lbb2ee:
	LDA ($00),Y
	INY
	CMP #$FF
	BEQ _lbb335
	CMP #$FE
	BEQ _lbb312
	CMP #$FD
	BEQ _lbb316
_lbb2fd:
	STA $0700,X
	LDA $02
	BPL _lbb30f
	LDA $03
	BNE _lbb30d
	STA $0700,X
	BEQ _lbb30f
_lbb30d:
	DEC $03
_lbb30f:
	INX
	BNE _lbb2ee
_lbb312:
	LDA #$FF
	BNE _lbb32e
_lbb316:
	LDA #$FF
	JSR _lbb32e
	LDA #$02
	STA $03
	LDA #$01
	JSR _lbb32e
	BNE _lbb2ee
	LDA #$FF
	BNE _lbb32c
	LDA #$00
_lbb32c:
	LDX $E7
_lbb32e:
	STA $0700,X
	INX
	STX $E7
	RTS
_lbb335:
	PHA
	LDA ($00),Y
	CMP #$FF
	BEQ _lbb344
	CMP #$FE
	BEQ _lbb344
	PLA
	STX $E7
	RTS
_lbb344:
	PLA
	JMP _lbb2fd
