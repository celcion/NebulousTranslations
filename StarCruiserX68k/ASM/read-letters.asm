;       org $2f58
	tst.w   $210(a6)
	bne.w   _write_8x8
_write_sjis:
	move.l  #-$1000000,d3
	lsr.l   d5,d3
	move.l  d3,d4
	not.l   d4
	moveq   #$f,d0
_read_byte16:
	move.b  (a1)+,d1
	lsl.w   #8,d1
	swap    d1
	clr.w   d1
	lsr.l   d5,d1
	move.l  d1,d2
	not.l   d2
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ori.b   #0,d0
	and.l   d4,(a0)
	or.l    d6,(a0)
	adda.l  #$20000,a0
	ori.b   #0,d0
	and.l   d4,(a0)
	or.l    d6,(a0)
	adda.l  #$20000,a0
	ori.b   #0,d0
	and.l   d4,(a0)
	or.l    d6,(a0)
	adda.l  #$20000,a0
	ori.b   #0,d0
	and.l   d4,(a0)
	or.l    d6,(a0)
	suba.l  #$5ff80,a0
	dbf     d0,_read_byte16
	;move.w  $1f0(a6),d0
	;lsr.w   #1,d0
	;add.w   d0,$200(a6)
	nop
	add.w   #$8,$200(a6)
	bra.w   _exit
_write_8x8:
	move.l  #-$4000000,d3
	lsr.l   d5,d3
	move.l  d3,d4
	not.l   d4
	moveq   #$7,d0
_read_byte:
	move.b  (a1)+,d1
	lsl.w   #8,d1
	swap    d1
	clr.w   d1
	lsr.l   d5,d1
	move.l  d1,d2
	not.l   d2
	ori.b   #0,d0
	and.l   d4,(a0)
	or.l    d6,(a0)
	adda.l  #$20000,a0
	ori.b   #0,d0
	and.l   d4,(a0)
	or.l    d6,(a0)
	adda.l  #$20000,a0
	ori.b   #0,d0
	and.l   d4,(a0)
	or.l    d6,(a0)
	adda.l  #$20000,a0
	ori.b   #0,d0
	and.l   d4,(a0)
	or.l    d6,(a0)
	suba.l  #$5ff80,a0
	dbf     d0,_read_byte
	move.w  $1f0(a6),d0
	lsr.w   #1,d0
	add.w   d0,$200(a6)
_exit:
	movem.l (sp)+,d1-d7/a1-a4
	rts
