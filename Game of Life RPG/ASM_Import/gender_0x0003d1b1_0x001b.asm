start: 0xD1A1
	LDA #$2B
	STA $85
	LDA #$21
	STA $86
	LDA $0740
	ASL
	TAY
	LDA $D1BC,Y
	STA $87
	LDA $D1BD,Y
	STA $88
	JSR $FFB1
	RTS