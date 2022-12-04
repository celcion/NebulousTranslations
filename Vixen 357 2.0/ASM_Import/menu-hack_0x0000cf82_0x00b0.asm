	org $0000cf82
start:
	andi.w  #$ff,d4
	move.w  d4,d1
	andi.w  #$7,d4
	or.w    d3,d1
	ori.w   #-$8000,d1
	addi.w  #$1,d1
	move.l  d7,d2
	bsr.b   write_font
	move    (sp)+,sr
	movem.l (sp)+,d0-d3/d7
	rts
	org $0000cfce
write_font:
	moveq   #0,d0
	move.w  d7,d0
	lsl.l   #2,d0
	lsr.w   #2,d0
	ori.w   #$4000,d0
	swap    d0
	move.l  d0,$c00004.l
	move.w  d1,$c00000.l
	rts
	movem.l d0-d6,-(sp)
	move.w  #$4000,d3
	move.w  d0,d5
	move.w  d1,d6
read:
	move.b  (a0)+,d4
	beq.b   exit
	cmpi.b  #-$1,d4
	beq.b   mod
	cmpi.b  #-$2,d4
	beq.b   read_add
	cmpi.b  #-$3,d4
	beq.b   read
	subq.b  #$1,d4
	;bsr.w   $cf74
	dc.w	$6100
	dc.w	$ff64
	;addq.w  #$2,d0
	addq.w  #$1,d0
	bra.b   read
mod:
	move.w  d5,d0
	;addq.w  #$2,d6
	addq.w  #$1,d6
	andi.w  #$1f,d6
	move.w  d6,d1
	bra.b   read
read_add:
	move.b  (a0)+,d3
	andi.w  #$ff,d3
	lsl.w   #8,d3
	bra.b   read
exit:
	movem.l (sp)+,d0-d6
	rts