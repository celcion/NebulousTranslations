	org $0000d0fc
	; Remove menu size doubling
start:
	sub.w   $ffffdc62.w,d0
	;sub.w   $dc62.w,d0
	nop
	nop
	subq.w  #$5,d0
	move.w  $22(a0),d1
	mulu.w  #$3,d1
	subq.w  #$1,d1
	move.w  $ffffdc60.w,d2
	add.w   d2,d2
	add.w   d1,d2
	addq.w  #$2,d2
	cmpi.w  #$14,d2
	bcs.b   skip
	subi.w  #$14,d2
	sub.w   d2,d1
skip:
	move.w  d0,$ffffdc64.w
	move.w  d1,$ffffdc66.w
	moveq   #0,d2
	move.w  $ffffdc62.w,d3
	;add.w   d3,d3
	nop
	addq.w  #$2,d3
	move.w  $ffffdc60.w,d4
	;add.w   d4,d4
	nop
	addq.w  #$2,d4
	moveq   #0,d5