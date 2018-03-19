start: 0x8000
%define PPUCTRL $2000
%define PPUMASK $2001
%define PPUSTATUS $2002
%define OAMADDR $2003
%define OAMDATA $2004
%define PPUSCROLL $2005
%define PPUADDR $2006
%define PPUDATA $2007
%define OAMDMA $4014
%define INIT_DST_HIGH #$20
%define INIT_DST_LOW #$A0
%define VAR_TIMER $41
%define VAR_SUBTIMER $47
%define VAR_SPACE $42
%define VAR_WRITE_OFFSET_HIGH $44
%define VAR_WRITE_OFFSET $43
%define VAR_CONTROL $40
%define VAR_SRC_HIGH $46
%define VAR_SRC_LOW $45
%define VAR_WRITE_TEXT $0703
%define VAR_WRITE $0700
	LDY #$00
	LDA VAR_CONTROL
	CMP #$00
	BNE _next1
	JMP _init
_next1:
	CMP #$01 ; Development
	BNE _next2
	LDA #$00
	STA VAR_SPACE
	JMP _textdata1
_next2:
	CMP #$02 ; First name
	BNE _next3 
	JMP _textdata1a1
_next3:
	CMP #$03 ; Second name
	BNE _next4
	JMP _textdata1a2
_next4:
	CMP #$04 ; timer
	BNE _next5
	JMP _timer
_next5:
	CMP #$05 ; Clear first name
	BNE _next6
	LDA #$20
	STA VAR_SPACE
	JMP _textdata1a1
_next6:
	CMP #$06 ; Clear second name
	BNE _next7
	JMP _textdata1a2
_next7:
	CMP #$07 ; Third name
	BNE _next8
	LDA #$00
	STA VAR_SPACE
	JMP _textdata1a3
_next8:
	CMP #$08 ; Fourth name
	BNE _next9
	JMP _textdata1a4
_next9:
	CMP #$09 ; timer
	BNE _nextA
	JMP _timer
_nextA:
	CMP #$0a ; Clear 3rd name
	BNE _nextB
	LDA #$20
	STA VAR_SPACE
	JMP _textdata1a3
_nextB:
	CMP #$0b ; Clear 4th name
	BNE _nextC
	JMP _textdata1a4
_nextC:
	CMP #$0c ; 5 name
	BNE _nextD
	LDA #$00
	STA VAR_SPACE
	;INC VAR_CONTROL
	JMP _textdata1a5
_nextD:
	CMP #$0d ; 6 name
	BNE _nextE
	JMP _textdata1a6
_nextE:
	CMP #$0e ; timer
	BNE _nextF
	JMP _timer
_nextF:
	CMP #$0f ; clear 5 name
	BNE _next10
	LDA #$20
	STA VAR_SPACE
	;INC VAR_CONTROL
	JMP _textdata1a5
_next10:
	CMP #$10 ; clear 6 name
	BNE _next11
	JMP _textdata1a6
_next11:
	CMP #$11 ; clear Development
	BNE _next12
	JMP _textdata1
_next12:
	CMP #$12 ; Art
	BNE _next13
	LDA #$00
	STA VAR_SPACE
	JMP _textdata2
_next13:
	CMP #$13 ; Art - 1-2 names
	BNE _next14
	JMP _textdata2a1
_next14:
	CMP #$14 ; Art - 3-4 names
	BNE _next15
	JMP _textdata2a2
_next15:
	CMP #$15
	BNE _next16
	JMP _timer
_next16:
	CMP #$16 ; clear art 1-2 names
	BNE _next17
	LDA #$20
	STA VAR_SPACE
	JMP _textdata2a1
_next17:
	CMP #$17 ; clear art 3-4 names
	BNE _next18
	JMP _textdata2a2
_next18:
	CMP #$18 ; clear Art
	BNE _next19
	JMP _textdata2
_next19:
	CMP #$19 ; sound
	BNE _next1a 
	LDA #$00
	STA VAR_SPACE
	JMP _textdata3
_next1a:
	CMP #$1a ; supervision
	BNE _next1b
	JMP _textdata4
_next1b:
	CMP #$1b
	BNE _next1c
	JMP _timer
_next1c:
	CMP #$1c ; clear sound
	BNE _next1d
	LDA #$20
	STA VAR_SPACE
	JMP _textdata3
_next1d:
	CMP #$1d ; clear supervision
	BNE _next1e
	JMP _textdata4
_next1e:
	CMP #$1e ; translators
	BNE _next1f
	LDA #$00
	STA VAR_SPACE
	JMP _textdata6
_next1f:
	CMP #$1f ; hackers
	BNE _next20
	JMP _textdata7
_next20:
	CMP #$20
	BNE _next21
	JMP _timer
_next21:
	CMP #$21 ; clear translators
	BNE _next22
	LDA #$20
	STA VAR_SPACE
	JMP _textdata6
_next22:
	CMP #$22 ; clear hackers
	BNE _next23
	JMP _textdata7
_next23:
	CMP #$23
	BNE _next24
	LDA #$01
	STA VAR_SUBTIMER
	JMP _timer
_next24:
	CMP #$24
	BNE _next25
	LDA #$00
	STA VAR_SPACE
	JMP _textdata5
_next25:
	RTS
_finish:
	LDA #$FF
	STA VAR_WRITE,Y
	INY
	LDA #$00
	STA VAR_WRITE,Y
	STY $e7
	LDA #%10101000 ;enable NMI, sprites from Pattern 0, background from Pattern 1
	STA $FF
	RTS
_init:
	INC VAR_CONTROL
	LDY #$00
	LDA #$01
	STA VAR_WRITE,Y
	INY
	LDA #$3f
	STA VAR_WRITE,Y
	INY
	LDA #$0a
	STA VAR_WRITE,Y
	INY
	LDA #$20
	STA VAR_WRITE,Y
	INY
	LDA #$FF
	STA VAR_WRITE,Y
	INY
	LDA #$01
	STA VAR_WRITE,Y
	INY
	LDA #$23
	STA VAR_WRITE,Y
	INY
	LDA #$60
	STA VAR_WRITE,Y
	INY
	LDX #$40
	LDA #$c0
_fillrow:
	STA VAR_WRITE,Y
	INY
	DEX
	BNE _fillrow
	JMP _finish
_loop:
	NOP
	LDA #$00
	;BEQ _loop
	RTS
_timer:
	INC VAR_TIMER
	LDA VAR_TIMER
	CMP #$ff
	BNE _timer1
	LDA VAR_SUBTIMER
	BNE _timer2
	INC VAR_SUBTIMER
	LDA #$00
	STA VAR_TIMER
	BEQ _timer1
_timer2:
	INC VAR_CONTROL
_timer1:
	RTS
_writetext:
	LDA #$00
	STA VAR_TIMER
	STA VAR_SUBTIMER
	LDA #$07
	STA VAR_WRITE_OFFSET_HIGH
	STY VAR_WRITE_OFFSET
	LDY #$00
	INC VAR_CONTROL
_startrow:
	LDA #$01 
	STA (VAR_WRITE_OFFSET),Y  ; first byte
	INC VAR_WRITE_OFFSET
	LDA (VAR_SRC_LOW),Y
	INC VAR_SRC_LOW
	BNE _startrow1
	INC VAR_SRC_HIGH
_startrow1:
	STA (VAR_WRITE_OFFSET),Y ; high byte of dst
	INC VAR_WRITE_OFFSET
	LDA (VAR_SRC_LOW),Y
	INC VAR_SRC_LOW
	BNE _startrow2
	INC VAR_SRC_HIGH
_startrow2:
	STA (VAR_WRITE_OFFSET),Y ; low byte of dst
	INC VAR_WRITE_OFFSET
_nextchar:
	LDA (VAR_SRC_LOW),Y
	INC VAR_SRC_LOW
	BNE _nextchar1
	INC VAR_SRC_HIGH
_nextchar1:
	CMP #$00
	BNE _wtext2
	LDY VAR_WRITE_OFFSET
	JMP _finish
_wtext2:
	TAX
	CMP #$FF
	BEQ _wtext3
	LDA VAR_SPACE
	CMP #$20
	BEQ _wtext3
	TXA
_wtext3:
	STA (VAR_WRITE_OFFSET),Y
	INC VAR_WRITE_OFFSET
	TXA
	CMP #$FF
	BNE _nextchar
	JMP _startrow
_textdata1:
	LDA #low(_textdata1x)
	STA VAR_SRC_LOW
	LDA #high(_textdata1x)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata1a1:
	LDA #low(_textdata1x1)
	STA VAR_SRC_LOW
	LDA #high(_textdata1x1)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata1a2:
	LDA #low(_textdata1x2)
	STA VAR_SRC_LOW
	LDA #high(_textdata1x2)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata1a3:
	LDA #low(_textdata1x3)
	STA VAR_SRC_LOW
	LDA #high(_textdata1x3)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata1a4:
	LDA #low(_textdata1x4)
	STA VAR_SRC_LOW
	LDA #high(_textdata1x4)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata1a5:
	LDA #low(_textdata1x5)
	STA VAR_SRC_LOW
	LDA #high(_textdata1x5)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata1a6:
	LDA #low(_textdata1x6)
	STA VAR_SRC_LOW
	LDA #high(_textdata1x6)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata2:
	LDA #low(_textdata2x)
	STA VAR_SRC_LOW
	LDA #high(_textdata2x)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata2a1:
	LDA #low(_textdata2x1)
	STA VAR_SRC_LOW
	LDA #high(_textdata2x1)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata2a2:
	LDA #low(_textdata2x2)
	STA VAR_SRC_LOW
	LDA #high(_textdata2x2)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata3:
	LDA #low(_textdata3x)
	STA VAR_SRC_LOW
	LDA #high(_textdata3x)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata4:
	LDA #low(_textdata4x)
	STA VAR_SRC_LOW
	LDA #high(_textdata4x)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata5:
	LDA #low(_textdata5x)
	STA VAR_SRC_LOW
	LDA #high(_textdata5x)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata6:
	LDA #low(_textdata6x)
	STA VAR_SRC_LOW
	LDA #high(_textdata6x)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata7:
	LDA #low(_textdata7x)
	STA VAR_SRC_LOW
	LDA #high(_textdata7x)
	STA VAR_SRC_HIGH
	JMP _writetext
_textdata1x:
	;.db $20,$a2
	.db $20,$aa
	.db "Development:\0"
_textdata1x1:
	.db $20,$e9
	.db "Super Hashimoto"
	.db $ff,$21,$06
	.db "<Kazuhisa Hashimoto>\0"
_textdata1x2:
	.db $21,$48
	.db "Cinnamon Kazuhiro"
	.db $ff,$21,$67
	.db "<Kazuhiro Aoyama>\0"
_textdata1x3:
	.db $20,$e9
	.db "Rambo Kazuyuki"
	.db $ff,$21,$06
	.db "<Kazuyuki Yamashita>\0"
_textdata1x4:
	.db $21,$4a
	.db "Windy Hitomi\0"
_textdata1x5:
	.db $20,$ea
	.db "Rhino Tsukasa"
	.db $ff,$21,$08
	.db "<Tsukasa Tokuda>\0"
_textdata1x6:
	.db $21,$48
	.db "Grasshopper Ogawa"
	.db $ff,$21,$68
	.db "<Mitsuaki Ogawa>\0"
_textdata2x:
	.db $20,$ae
	.db "Art:\0"
_textdata2x1:
	.db $20,$ea
	.db "Willow Reika"
	.db $ff,$21,$2a
	.db "Moon Nakamoto\0"
_textdata2x2:
	.db $21,$6b
	.db "Lady Arisu"
	.db $ff,$21,$aa
	.db "Susumu Kusaka\0"
_textdata3x:
	.db $20,$ad
	.db "Sound:"
	.db $ff,$20,$ed
	.db "Michael"
	.db $ff,$21,$07
	.db "<Hidenori Maezawa>\0"
_textdata4x:
	.db $21,$6b
	.db "Supervision:"
	.db $ff,$21,$aa
	.db "Konamimantaro\0"
_textdata5x:
	.db $21,$6e
	;.db "E N D\0"
	.db $80,$81,$82,$83,$84
	.db $ff,$21,$8e
	.db $90,$91,$92,$93,$94
	.db $ff,$21,$ae
	.db $86,$87,$88,$89,$8a
	.db $ff,$21,$ce
	.db $96,$97,$98,$99,$9a,$00
_textdata6x:
	.db $20,$a6
	.db "English translation:"
	.db $ff,$20,$ea
	.db "TheMajinZenki"
	.db $ff,$21,$2d
	.db "cccmar\0"
_textdata7x:
	.db $21,$84
	.db "Hacking and programming:"
	.db $ff,$21,$cd
	.db "Celcion"
	.db $ff,$22,$0c
	.db "Miralita\0"