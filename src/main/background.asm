
 SECTION "Background", ROM0

InitializeBackground:

	ld a, 0
	ld [mBackgroundScroll+0],a
	ld a, 0
	ld [mBackgroundScroll+1],a
    
    ret

ScrollBackground:

    ; What game state is it
    ; We wont scroll the background until we are in the active gameplay game state
    ld a, [wGameState]
    cp a, 2
    ret nz

	ld a, [mBackgroundScroll+0]
	ld b, a
	ld a, [mBackgroundScroll+1]
	ld c, a

	; load the lower byte into b
	; increase the lower byte by our vertical speed
	ld a, c
	add a, HORIZONTAL_MOVE_SPEED
	ld c ,a

	;  add the remainder to the upper byte
	ld a, b
	adc a, 0
	ld b, a

	
	ld hl, mBackgroundScroll
	ld a, b
	ld [hli], a
	ld a, c
	ld  [hld],a

	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c

	ld a, c
	ld [mBackgroundScrollReal], a


    ret

UpdateCameraPosition:

	ld hl, rSCX
	ld a, [mBackgroundScrollReal]
	ld [rSCX], a
	ret;

SECTION "BackgroundVariables", WRAM0

mBackgroundScroll: dw
mBackgroundScrollReal: db