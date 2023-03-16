

 DEF PIPES_BYTE_COUNT EQU 4
 DEF PIPES_COUNT EQU 1
 DEF PIPE_NOT_VISIBLE EQU 0
 DEF PIPE_VISIBLE EQU 1
 DEF TOP_PIPE EQU 1
 DEF BOTTOM_PIPE EQU 0

SECTION "PipeVariables", WRAM0

wPipeSpriteCount: db
wPipeScroller: db
wPipeScrollerCounter: dw
wCurrentSpriteAddress: dw
wCurrentPipeAddress: dw
wPipeSprite: db
wPipeCounter: db;
wPipes: ds PIPES_BYTE_COUNT*PIPES_COUNT
; visible = 1, invisible = 0
; x position low
; x position high 
; Top = 1, Bottom = 0

wDrawVerticalSide:db
wDrawHorizontalSide:db
wDrawHeight:DB

 SECTION "Pipes", ROM0

InitPipes:

    ld a, 1
    ld [wPipes+0], a
    ld [wPipes+3], a
    ld a, 0
    ld [wPipes+1], a
    ld [wPipes+2], a

    ld a, 1
    ld [wPipes+4], a
    ld [wPipes+7], a
    ld a, 0
    ld [wPipes+5], a
    ld [wPipes+6], a

    ld a, 1
    ld [wPipes+8], a
    ld [wPipes+11], a
    ld a, 0
    ld [wPipes+9], a
    ld [wPipes+10], a

    ld a, 1
    ld [wPipes+12], a
    ld [wPipes+15], a
    ld a, 0
    ld [wPipes+13], a
    ld [wPipes+14], a

UpdatePipes:

    ld a, 0
    ld [wPipeCounter], a

    ld hl, wPipes
    ld a, l
    ld [wCurrentPipeAddress+0],a
    ld a, h
    ld [wCurrentPipeAddress+1], a

    jp UpdatePipesLoop

UpdateNextPipe:


    ld a, [wPipeCounter]
    inc a
    ld [wPipeCounter], a
    cp a, PIPES_COUNT+1
    ret z

    IncreaseAddress wCurrentPipeAddress, PIPES_BYTE_COUNT

UpdatePipesLoop:

    LoadAddressIntoHL wCurrentPipeAddress, 0
    
    ld a, [hli]
    cp a, PIPE_VISIBLE

    jp nz, UpdateNextPipe

    ; Get our x position low byte  (and increment)
    ld a, [hl]
    sub a, HORIZONTAL_MOVE_SPEED ; apply motion
    ld [hli],a
    ld c, a ; save the low byte in c

    ; Get our high byte
    ld a, [hl]
    sbc a, 0 ; apply the carry over and update
    ld [hli],a
    ld b, a

    ; Get the actual value
    srl b
    rr c
    srl b
    rr c
    srl b
    rr c
    srl b
    rr c

    ld h, c
    ld l , 0
    push hl

    ; y = 16 ( taking into consideration the negative 16 offset)
	ld a, 16
	ld [wDrawMetasprites_MetaspritePosition.y], a

	ld a, c
	ld [wDrawMetasprites_MetaspritePosition.x], a

    LoadMetaspriteAddressAndDraw wTopPipe1

    pop hl

    ; y = 160 ( taking into consideration the negative 16 offset)
	ld a, 160
	ld [wDrawMetasprites_MetaspritePosition.y], a

	ld a, h
	ld [wDrawMetasprites_MetaspritePosition.x], a

    LoadMetaspriteAddressAndDraw wBottomPipe1

    jp UpdateNextPipe


wTopPipe1:
    .count db 6
    .row1a db 0, 0, 0 ,0
    .row1b db 0, 8, 0 ,0
    .row2a db 16, -8, 0 ,0
    .row2b db 0, 8, 0 ,0
    .row3a db 16, -8, 0 ,0
    .row3b db 0, 8, 0 ,0

    
wBottomPipe1:
    .count db 6
    .row1a db -16, 0, 0 ,0
    .row1b db 0, 8, 0 ,0
    .row2a db -16, -8, 0 ,0
    .row2b db 0, 8, 0 ,0
    .row3a db -16, -8, 0 ,0
    .row3b db 0, 8, 0 ,0