
 SECTION "Pipes", ROM0


UpdatePipes:

	; Save 4 sprites (16 bytes) for the player
	; Save the address of our 5th sprite in wCurrentSpriteAddress
	ld hl, _OAMRAM
	ld bc, 16
	add hl, bc
	ld a, h
	ld [wCurrentSpriteAddress+1],a
	ld a, l
	ld [wCurrentSpriteAddress+0],a

	; Save the address of the first pipe in wCurrentPipeAddress
	ld hl, wPipes
	ld a, h
	ld [wCurrentPipeAddress+1],a
	ld a, l
	ld [wCurrentPipeAddress+0],a

	; Reeset our pipe counter
	ld a, 0
	ld [wPipeCounter], a

UpdatePipesLoop:

    ld a, [wCurrentPipeAddress+0]
    ld l, a
    ld a, [wCurrentPipeAddress+1]
    ld h, a

    ld a, [hl]
    add a, 0
    jp z, MoveToNextPipe


    ld a,0
    ld [wDrawVerticalSide], a

DrawSide:


    ld a,0
    ld [wDrawHorizontalSide], a
    ld [wDrawHeight], a
    
	ld b, 0
    ld c, 0

DrawSpriteLoop:

    ; Get the address of our current sprite
    ld a, [wCurrentSpriteAddress+0]
    ld l, a
    ld a, [wCurrentSpriteAddress+1]
    ld h, a
    ld a, [wDrawHeight]
    ld b, a
	ld a, [wDrawVerticalSide]
    add a, b
	ld [hli], a
    ld a, [wDrawHorizontalSide]
    ld b, a
	ld a, 80+8
    add a, b
	ld [hli], a
	ld a, 0 ; Use tile zero
	ld [hli], a
	ld [hl], a

    
    ; Get the address of our current sprite
    ld a, [wCurrentSpriteAddress+0]
    ld l, a
    ld a, [wCurrentSpriteAddress+1]
    ld h, a

    ld a, l
    add a, 4
    ld [wCurrentSpriteAddress+0], a
    ld a, h
    adc a, 0
    ld [wCurrentSpriteAddress+1], a

    ld a, [wDrawHorizontalSide]
    cp a, 0

    jp nz, IncreaseC

    ld a, [wDrawHorizontalSide]
    add a, 8
    ld [wDrawHorizontalSide], a

    jp DrawSpriteLoop
    

IncreaseC:

    ld a, 0
    ld [wDrawHorizontalSide],a

    ld a, [wDrawHeight]
    add a, 16
    ld [wDrawHeight], a
    
    cp a, 64

    jp z, DoneWithSide

    jp DrawSpriteLoop

DoneWithSide:

    ld a, [wDrawVerticalSide]
    add a, 0
    jp nz, MoveToNextPipe

    ld a, 100
    ld [wDrawVerticalSide], a
    
    jp DrawSide


MoveToNextPipe:

	; increase our counter
	ld a, [wPipeCounter]
	inc a
	ld [wPipeCounter], a

	; Skip over the next 5 bytess
	ld a, [wCurrentPipeAddress+0]
	add a, 5
	ld [wCurrentPipeAddress+0], a
	ld a, [wCurrentPipeAddress+1]
	adc a, 0
	ld [wCurrentPipeAddress+0], a

	ld a, [wPipeCounter]
    cp a, 4
    jp z, UpdatePipesLoop

    ret


SECTION "PipeVariables", WRAM0


wCurrentSpriteAddress: dw
wCurrentPipeAddress: dw
wPipeSprite: db
wPipeCounter: db;
wPipes: ds 20

wDrawVerticalSide:db
wDrawHorizontalSide:db
wDrawHeight:db
; visible = 1, invisible = 0
; Top = 1, Bottom = 0
; Active = 1 ,Inactive = 0
; Vertical
; offsetX

