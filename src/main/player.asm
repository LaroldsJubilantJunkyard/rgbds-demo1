
 SECTION "Player", ROM0


InitializePlayer:

	ld a,0
	ld [mBallVelocity+0], a
	ld [mBallVelocity+1], a

	ld a, 0
	ld [wBallPosition.y+0], a
	ld a, 5
	ld [wBallPosition.y+1], a

	ld a, 0
	ld [wBallPosition.x+0], a
	ld a, 0
	ld [wBallPosition.x+1], a

    ret

UpdatePlayer:


    ; What game state is it
    ld a, [wGameState]
    cp a, 2
    jp z, AciveGameState
    cp a, 1
    jp z, ReadyGameState



	ld a, 0
	ld [wBallPosition.y+0], a
	ld a, 5
	ld [wBallPosition.y+1], a

	Increase16BitValue wBallPosition.x, HORIZONTAL_MOVE_SPEED

    
    call UpdatePlayerSpriteOAMPosition

	ld a, [wBallPosition.x+0]
    ld b, a
	ld a, [wBallPosition.x+1]
    ld c, a

    srl c
    rr b
    srl c
    rr b
    srl c
    rr b
    srl c
    rr b

    ld a, b

    cp a, 80

    ret c

    
    ld a, 1
    ld [wGameState], a
    

    ret

ReadyGameState:

    ; Check the current keys every frame and move left or right.
	; This is in input.asm
	; It's straight from: https://gbdev.io/gb-asm-tutorial/part2/input.html
	; In their words (paraphrased): reading player input for gameboy is NOT a trivial task
	; So it's best to use some tested code
    call Input

	ld a, [wCurKeys]
	and a, PADF_UP
	ret z

    ld a, 2
    ld [wGameState], a

    call MoveUp

    ret

AciveGameState:

    call PollForInput

	Increase16BitValue mBallVelocity, GRAVITY_SPEED
	
	; Decrease our low byte by gravity
	ld a, [mBallVelocity+0]
	ld b, a
	ld a, [mBallVelocity+1]
	ld c, a

	ld d,c

	; turn off the most significant bit before we apply
	ld a, c
	and a, %01111111
	ld c, a

	srl c
	rr b
	srl c
	rr b
	srl c
	rr b
	srl c
	rr b

	bit 7, d

	jp z, IncreasePlayerYPosition
	jp DecreasePlayerYPosition

LimitB:

	ld a, 16
	ld b, a

ret

DecreasePlayerYPosition:

	Decrease16BitValue wBallPosition.y, b
    call UpdatePlayerSpriteOAMPosition
	ret


IncreasePlayerYPosition:

	ld a,b
	cp a, 16

	call c, LimitB

	Increase16BitValue wBallPosition.y, b
    call UpdatePlayerSpriteOAMPosition

	ret


UpdatePlayerSpriteOAMPosition:

	; load our value into bc
	ld a, [wBallPosition.y+1]
	ld b, a
	ld a, [wBallPosition.y+0]
	ld c, a

	; x4 = division by 16
	; Shift the high bit
	; rotate the carry over to the low bit
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c

	; Get our low bit
	; that's our y coordinate
	ld d, c


	; load our value into bc
	ld a, [wBallPosition.x+1]
	ld b, a
	ld a, [wBallPosition.x+0]
	ld c, a

	; x4 = division by 16
	; Shift the high bit
	; rotate the carry over to the low bit
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c
	srl b
	rr c

	
	ld a, d
	ld [wDrawMetasprites_MetaspritePosition.y], a
	ld a, c
	ld [wDrawMetasprites_MetaspritePosition.x], a

	LoadMetaspriteAddressAndDraw wCircleSprite

	ret

PollForInput:


	; Save the current keys in the last variable
	ld a, [wCurKeys]
	ld [wLastKeys], a

    ; If our up button was pressed previously
    ; skip the ability to moveup
	ld a, [wLastKeys]
	and a, PADF_UP
    jp nz, SkipInput

    ; Check the current keys every frame and move left or right.
	; This is in input.asm
	; It's straight from: https://gbdev.io/gb-asm-tutorial/part2/input.html
	; In their words (paraphrased): reading player input for gameboy is NOT a trivial task
	; So it's best to use some tested code
    call Input

	ld a, [wCurKeys]
	and a, PADF_UP
	call nz, MoveUp

    ret

SkipInput:

    ; Check the current keys so our wCurKeys variable updates again
    ; Check the current keys every frame and move left or right.
	; This is in input.asm
	; It's straight from: https://gbdev.io/gb-asm-tutorial/part2/input.html
	; In their words (paraphrased): reading player input for gameboy is NOT a trivial task
	; So it's best to use some tested code
    call Input

	ret

MoveUp:

	ld a, MAX_SPEED
	ld [mBallVelocity+0], a

	ld a, %10000000
	ld [mBallVelocity+1], a

	ret




wCircleSprite:
	.total db 1
	.y db 0
	.x db 0
	.paette db 0


SECTION "PlayerVariables", WRAM0

; Our ball's position
; first byte is high, second is low
wBallPosition: 
	.x dw
	.y dw

mBallVelocity: dw