
 SECTION "Player", ROM0


InitializePlayer:

	ld a,0
	ld [mBallVelocityDirection], a

	ld a,0
	ld [mBallVelocity], a

	ld a, 5
	ld [wBallPosition.y+0], a
	ld a, 0
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


	ld a, 5
	ld [wBallPosition.y+0], a
	ld a, 0
	ld [wBallPosition.y+1], a

	ld a, [wBallPosition.x+1]
    add a, HORIZONTAL_MOVE_SPEED
    ld [wBallPosition.x+1], a
    ld a, [wBallPosition.x+0]
    adc a, 0
    ld [wBallPosition.x+0], a
    
    call UpdatePlayerSpriteOAMPosition

	ld a, [wBallPosition.x+0]
    ld b, a
	ld a, [wBallPosition.x+1]
    ld c, a

    srl b
    rr c
    srl b
    rr c
    srl b
    rr c
    srl b
    rr c

    ld a, c

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

	; Get th hi
	ld a, [mBallVelocityDirection]
	cp a, 0

	; Go to the proper moving direction
	call z, MovingDown

	; Get the ball direction
	ld a, [mBallVelocityDirection]
	cp a, 0

	call nz, MovingUp

	ret

MovingUp:


	call DecreaseVelocingMovingUp
	call c, SwitchToMovingDown 

	jp ApplyVelocity

SwitchToMovingDown:

	ld a, 0
	ld [mBallVelocityDirection],a
	ld [mBallVelocity],a

	ret

MovingDown:

	; Check our velocity
	ld a, [mBallVelocity]
	cp a, MAX_SPEED

	; if our value is at MAX_SPEED
	; Skip increase
	jp z, ApplyVelocity

	jp nc, IncreaseVelocityMovingDown

	ld a, MAX_SPEED
	ld [mBallVelocity], a

	jp ApplyVelocity

DecreaseVelocingMovingUp:

	; Decrease our velocity
	ld a, [mBallVelocity]
	sub a, GRAVITY_SPEED
	ld [mBallVelocity], a

	call c, SwitchToMovingDown 
	

	ret

IncreaseVelocityMovingDown:

	ld [mBallVelocity], a
	add a, GRAVITY_SPEED
	ld [mBallVelocity], a

	jp ApplyVelocity

ApplyVelocity:

	ld a, [mBallVelocity]

	; Get the non-scaled version of our velocity
	; Shift right to divide
	srl a
	srl a
	srl a
	srl a

	; save our non scaled version (the low bit) of velocity in d
	ld d, a

	ld a, [mBallVelocityDirection]
	cp a, 0

	;
	jp nz,ApplyVelocityMovingUp
	jp ApplyVelocityMovingDown

ApplyVelocityMovingDown:

	; Get
	ld a, [wBallPosition.y+0]
	ld b, a
	ld a, [wBallPosition.y+1]
	ld c, a

	; load the low byte into a
	; increase by d
	; 
	ld a, c
	add a, d
	ld c, a
	ld a, b
	adc a, 0
	ld b, a

    ; Update our y position variable
	ld hl, wBallPosition.y
	ld a,  b
	ld  [hli], a
	ld a,  c
	ld  [hld], a

	jp UpdatePlayerSpriteOAMPosition

ApplyVelocityMovingUp:

	; Get
	ld a, [wBallPosition.y+0]
	ld b, a
	ld a, [wBallPosition.y+1]
	ld c, a

	; load the low byte into a
	; increase by d
	; 
	ld a, c
	sub a, d
	ld c, a
	ld a, b
	sbc a, 0
	ld b, a

    ; Update our y position variable
	ld hl, wBallPosition.y
	ld a,  b
	ld  [hli], a
	ld a,  c
	ld  [hld], a

	jp UpdatePlayerSpriteOAMPosition

UpdatePlayerSpriteOAMPosition:

	; load our value into bc
	ld a, [wBallPosition.y+0]
	ld b, a
	ld a, [wBallPosition.y+1]
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
	ld a, [wBallPosition.x+0]
	ld b, a
	ld a, [wBallPosition.x+1]
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

	ld a, 1
	ld [mBallVelocityDirection], a
	ld a, MAX_SPEED
	ld [mBallVelocity], a


	ret



SECTION "PlayerVariables", WRAM0

; Our ball's position
; first byte is high, second is low
wBallPosition: 
	.x dw
	.y dw

mBallVelocity: db
mBallVelocityDirection: db