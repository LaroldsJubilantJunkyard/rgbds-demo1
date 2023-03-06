
IncreaseTwoBytes_PointedToByHL_ByB:
	
	ld a,l
	add a, 1
	ld l, a

	ld a, h
	adc a, 0
	ld h, a

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Increase the x position of the ball ;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; load our low byte value into a
	; Add some to the low byte
	; then update our low byte register (l) and wram variable
	ld a, [hl] 
	add a, b
	ld [hl] ,a

	; Save this carry over in b
	ld a, 0
	adc a,0
	ld b,a

	ld a, l
	sub a, 1
	ld l, a

	ld a, h
	sbc a, 0
	ld h, a

	; load our high byte value into a
	; add the carry over from the previous add to our high byte
	; then updae our high byte register (h) and wram varaible
	ld a, [hl] 
	adc a, b
	ld [hl] ,a

	ret

DecreaseTwoBytes_PointedToByHL_ByB:
	
	ld a,l
	add a, 1
	ld l, a

	ld a, h
	adc a, 0
	ld h, a

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Decrease the x position of the ball ;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; load our low byte value into a
	; subtract some from the low byte
	; then update our low byte  wram variable
	ld a, [hl] 
	sub a, b
	ld [hl] ,a

	; Save this carry over in b
	ld a, 0
	adc a,0
	ld b,a

	ld a,l
	sub a, 1
	ld l,a

	ld a, h
	sbc a, 0
	ld h, a

	; load our high byte value into a
	; subtract the carry over from the previous add to our low byte
	; then update our high byte  wram varaible
	ld a, [hl] 
	sbc a, b
	ld [hl] ,a

	ret