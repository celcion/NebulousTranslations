start: 0xD146
	ASL
	TAY
	LDA $D165,Y
	STA $85
	LDA $D166,Y
	STA $86
	LDA $0740
	ASL
	TAY
	LDA $D16B,Y
	STA $87
	LDA $D16C,Y
	STA $88
	JSR $C9D5
	RTS