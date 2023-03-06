

Update_SpriteB_XPosition_ToValuePointedToByHL:

	push hl

	call ShiftValuePointedToByHL_AndStoreResultInHL

	ld c,1 ; which oam attribute (will be external)
	call Update_SpriteB_AttributeC_UsingLowerByteInHL

	pop hl

	ret

Update_SpriteB_YPosition_ToValuePointedToByHL:

	push hl
	
	call ShiftValuePointedToByHL_AndStoreResultInHL

	ld c,0 ; which oam attribute (will be external)
	call Update_SpriteB_AttributeC_UsingLowerByteInHL

	pop hl

	ret

ShiftValuePointedToByHL_AndStoreResultInHL:

	ld a, [hli]
	ld d, a
	ld a, [hld]
	ld e, a

	; Shift the high byte to the right
	; Then rand carry over 
	; repeat multiple times
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e

	ld a, d
	ld h, a
	ld a, e
	ld l, a

	ret

Update_SpriteB_AttributeC_UsingLowerByteInHL:
	
	; Get the address of sprite 0's x position
	ld de, _OAMRAM
	
	; Add the oam attribute from c
	; add b (which oam attribute, 0-3) to d
	ld a, e
	add a, c
	ld e,a

	; Add the carry over to e
	ld a, d
	adc a, 0
	ld d,a

Update_SpriteB_AttributeC_UsingLowerByteInHL_Loop:

	;; Is the sprite 0?
	ld a, b
	cp a, 0

	;; If b is zero, start the update
	jp z, Update_SpriteB_AttributeC_UsingLowerByteInHL_Finish

	; Decrease de by 4
	ld a, e
	add a, 4
	ld e, a

	ld a, d
	adc a, 0
	ld d,a

	;; Decrease b by 1
	ld a, b
	dec a
	ld b, a

	jp Update_SpriteB_AttributeC_UsingLowerByteInHL_Loop

Update_SpriteB_AttributeC_UsingLowerByteInHL_Finish:

	; Copy the lower byte into the x position
	ld a, l
	ld [de], a

	ret