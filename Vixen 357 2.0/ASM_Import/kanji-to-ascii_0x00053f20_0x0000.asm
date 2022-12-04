start:
	movem.l d0-d6/a0-a2,-(sp)
	cmpi.w  #$0001,d2
	bne	NotASpace
	move.w	#$2020,d2
NotASpace:
	movem.l d2,-(sp)
	lsr.w   #$08,d2
	subi.b 	#$20,d2
	add.w	d0,d0
	LSL.w	#6,d1
	ADD.w	d1,d0
	LSL.w	#5,d0
	ADD.w	$FFFFB76E.w,d0
	MOVE.w	d2,d4
;	ANDI.w	#$07F8, D4
	ANDI.w	#$07F0,d4
	DIVU.w	#$2,d4
	LSL.w	#7,d4
	MOVE.w	d2,d5
	ANDI.w	#$f,d5
	LSL.w	#5,d5 ; надо поменять на 5
	;LEA	$00115000,a0
	LEA	$ff3a00,a0
	ADDA.w	d4,a0
	ADDA.w	d5,a0
	ROL.w	#4,d2
	ANDI.w	#6,d2
	move.w  #$1111,d1
	MOVEA.l	$FFFF80B6,a1
	MOVE.w	#$FFF7,(a1)+
	MOVE.w	d0,(a1)+
	MOVE.w	#$0020,(a1)+
	JSR	$0000B192		; goto прочитать символ
	movem.l (sp)+,d2
	move.l  a0,a2     ; сохраним A0, получившийся после первого прохода
	lsl.w   #$08,d2
	lsr.w   #$08,d2
	subi.b	#$20,d2
	MOVE.w	d2,d4
;	ANDI.w	#$07F8, D4
	ANDI.w	#$07F0,d4
	DIVU.w	#$2,d4
	LSL.w	#7,d4
	MOVE.w	d2,d5
	ANDI.w	#$f,d5
	LSL.w	#5,d5 ; надо поменять на 5
	;LEA	$00115000,a0
	LEA	$ff3a00,a0
	ADDA.w	d4,a0
	ADDA.w	d5,a0
	JSR	$0000B192		; goto прочитать символ
	exg.l   a0,a2	; разменяем A0 с тем, что сохранили 
	MOVE.l	a1,$FFFF80B6
	ADDI.w	#$0400,d0
	ADDA.w	#$01E0,a0
	MOVEA.l	$FFFF80B6,a1
	MOVE.w	#$FFF7,(a1)+
	MOVE.w	d0,(a1)+
	MOVE.w	#$0020,(a1)+
	JSR	$0000B192
	move.l  a2,a0
	ADDA.w	#$01E0,a0
	JSR	$0000B192
	MOVE.l	a1,$FFFF80B6
	MOVEM.l	(sp)+,d0-d6/a0-a2
	RTS
