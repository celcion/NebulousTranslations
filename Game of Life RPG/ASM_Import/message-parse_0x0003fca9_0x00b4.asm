start: 0xFC99
_initialize:
	LDX #$00
	LDY #$00
_read_byte:
	LDA $06C0,Y
	CMP #$FF
	BEQ _exit
	CMP #$FD
	BEQ _insert_code
	CMP #$FC
	BEQ _insert_dict
	CMP #$FB
	BEQ _insert_dict
	CMP #$FA
	BEQ _insert_dict
	STA $0160,X
	INX
	INY
	JMP _read_byte
_insert_code:
	TYA
	PHA
	JSR _jump_code
	PLA
	TAY
	INY
	INY
	JMP _read_byte
_exit:
	STA $0160,X
	RTS
_jump_code:
	INY
	LDA $06C0,Y
	ASL
	TAY
	LDA $FD87,Y
	STA $49
	LDA $FD88,Y
	STA $4A
	JMP ($0049)
_insert_dict:
	TYA
	PHA
	LDA #$06
	LDY #$1C ; starts at 0x38010
	JSR $CF94
	PLA
	TAY
	LDA $06C1,Y
	STA $BA
	LDA $06C0,Y
	SEC
	SBC #$FA
	STA $BB
	CLC
	ASL $BA
	LDA $BB
	ROL
	CLC
	ADC #$90
	STA $BB
	INY
	INY
	TYA
	PHA
	LDY #$00
	LDA ($BA),Y
	STA $4B ; NOT SURE!
	INY
	LDA ($BA),Y
	STA $4C ; NOT SURE!
	LDY #$00
_insert_dict_read_byte:
	LDA ($4B),Y
	CMP #$FF
	BEQ _insert_dict_exit
	STA $0160,X
	INX
	INY
	JMP _insert_dict_read_byte
_insert_dict_exit:
	JSR $FF55
	PLA
	TAY
	JMP _read_byte
