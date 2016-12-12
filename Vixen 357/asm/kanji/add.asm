; DA000 - вставка кода
; 4660A - начинается текст
	MOVEM.l	A2/A1/A0/D6/D5/D4/D3/D2/D1/D0, -(A7)	;Predicted (Code-scan)
	cmpi.w  #$0001, D2
	bne	NotASpace
	move.w	#$2020, D2
NotASpace:
	movem.l D2, -(sp)
	lsr.w   #$08, D2
	sub.b 	#$20, D2
	ADD.w	D0, D0
	LSL.w	#6, D1
	ADD.w	D1, D0
	LSL.w	#5, D0
	ADD.w	$FFFFB76E.w, D0
	MOVE.w	D2, D4
;	ANDI.w	#$07F8, D4
	ANDI.w	#$07F0, D4
	DIVU.w	#$2,D4
	LSL.w	#7, D4
	MOVE.w	D2, D5
	ANDI.w	#$f, D5
	LSL.w	#5, D5 ; надо поменять на 5
	LEA	$00115000, A0
	ADDA.w	D4, A0
	ADDA.w	D5, A0
	ROL.w	#4, D2
	ANDI.w	#6, D2
	move.w  #$1111, D1
	MOVEA.l	$FFFF80B6, A1
	MOVE.w	#$FFF7, (A1)+
	MOVE.w	D0, (A1)+
	MOVE.w	#$0020, (A1)+
	JSR	$0000B192		; goto прочитать символ
	movem.l (sp)+, D2
	move.l  A0, A2     ; сохраним A0, получившийся после первого прохода
	lsl.w   #$08, D2
	lsr.w   #$08, D2
	sub.b	#$20, D2
	MOVE.w	D2, D4
;	ANDI.w	#$07F8, D4
	ANDI.w	#$07F0, D4
	DIVU.w	#$2,D4
	LSL.w	#7, D4
	MOVE.w	D2, D5
	ANDI.w	#$f, D5
	LSL.w	#5, D5 ; надо поменять на 5
	LEA	$00115000, A0
	ADDA.w	D4, A0
	ADDA.w	D5, A0
	JSR	$0000B192		; goto прочитать символ
	exg.l   A2, A0	; разменяем A0 с тем, что сохранили 
	MOVE.l	A1, $FFFF80B6
	ADDI.w	#$0400, D0
	ADDA.w	#$01E0, A0
	MOVEA.l	$FFFF80B6, A1
	MOVE.w	#$FFF7, (A1)+
	MOVE.w	D0, (A1)+
	MOVE.w	#$0020, (A1)+
	JSR	$0000B192
	move.l  A2, A0
	ADDA.w	#$01E0, A0
	JSR	$0000B192
	MOVE.l	A1, $FFFF80B6
	MOVEM.l	(A7)+, D0/D1/D2/D3/D4/D5/D6/A0/A1/A2
	RTS
