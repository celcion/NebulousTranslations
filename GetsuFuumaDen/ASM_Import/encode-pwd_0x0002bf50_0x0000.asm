start: 0xbf40
;BEA3 - JSR (20 40 bf)
	LDA $0702
	CMP #$ec
	BNE _next1
	LDA #$01
	STA $41
_next1:
	LDA $41
	BEQ _clear
	LDA $0600,X
	CMP #$5b
	BMI _return
	CLC
	ADC #$06
_return:
	RTS
_clear:
	LDA $0600,X
	CMP #$6e
	BNE _return
	CLC
	ADC #$0c
	RTS