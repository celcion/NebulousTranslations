start: 0xFF64
; FF64
_change_page:
	LDA #$06
	LDY #$16 ; starts at 0x2C010
	JSR $CF94
	RTS
; FF6C
_return_page:
	JSR $FF55
	RTS
; String loading (load from 004D, write to 004F ptrs)
; FF70
_load_4d4f:
	JSR _change_page
	LDY #$00
_load_4d4f_repeat:
	LDA ($4D),Y
	CMP #$FF
	BEQ _return_page
	STA ($4F),Y
	INY
	JMP _load_4d4f_repeat
; String loading (load from 004B, write to 0051 ptrs)
; FF81
_load_4b51:
	JSR _change_page
	LDY #$00
_load_4b51_repeat:
	LDA ($4B),Y
	CMP #$FF
	BEQ _return_page
	STA ($51),Y
	INY
	JMP _load_4b51_repeat
; String loading (load from 004F, write to 0051 ptrs)
; FF92
_load_4f51:
	JSR _change_page
	LDY #$00
_load_4f51_repeat:
	LDA ($4F),Y
	CMP #$FF
	BEQ _return_page
	STA ($51),Y
	INY
	JMP _load_4f51_repeat
; Replace function for skills loading in messages
; FFA3
_load_skills_messages:
	LDA ($4B),Y
	CMP #$FF
	BEQ _return_page
	STA $0160,X
	INX
	INY
	JMP _load_skills_messages
; Switch page and call line reading
; FFB1
_read_line:
	JSR _change_page
	JSR $C9D5
	JMP _return_page
; Load for items in messages
; FFBA
_read_items:
	JSR _change_page
	LDY #$02
	JMP _load_skills_messages
; Load for inventory in messages
; FFC2
_read_inventory:
	JSR _change_page
	LDY #$00
	JMP _load_skills_messages
