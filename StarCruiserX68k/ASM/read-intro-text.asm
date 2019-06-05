_start:
	moveq #$0,d0
	move.b (a0)+,d0
	beq _exit
	or.w #$8000,d0
	move.w d0,-(a7)
	dc.w $a001
	addq.l #2,a7
	bra _start
_exit:
	;move.b (a0)+,d0 ; delete this after script insertion!
	rts
