start: 0x8000
	LDY #$00
	BEQ _select_ptr_block
	LDY #$01
_select_ptr_block:
	STY $08
	ASL
	TAY
	BCC _first_ptr_block
	LDA $81FC,Y
	STA $02
	LDA $81FD,Y
	JMP _begin_reading
_first_ptr_block:
	LDA $80FC,Y
	STA $02
	LDA $80FD,Y
_begin_reading:
	STA $03
	LDY #$01
	STY $06
	LDY #$00
_line_read:
	JSR _set_coordinates
	LDA #$19
	STA $07
	LDA $08
	BEQ _read_char
	JSR _add_left_border
_read_char:
	LDA ($02),Y
	CMP #$FF
	BNE _write_char
	LDA #$00
_finish_line:
	STA $0700,X
	INX
	DEC $07
	BPL _finish_line
	JMP _check_for_border
_write_char:
	STA $0700,X
	INX
	INY
	DEC $07
	BPL _read_char
_check_for_border:
	LDA $08
	BEQ _line_end
	JSR _add_left_border
_line_end:
	LDA #$FF
	STA $0700,X
	INX
	STX $E7
	LDA $04
	CLC
	ADC #$20
	STA $04
	LDA $05
	ADC #$00
	STA $05
	INY
	DEC $06
	BPL _line_read
	RTS
_set_coordinates:
	LDX $E7
	LDA #$01
	STA $0700,X
	INX
	LDA $05
	STA $0700,X
	INX
	LDA $04
	STA $0700,X
	INX
	RTS
_add_left_border:
	LDA #$13
	STA $0700,X
	INX
	RTS
