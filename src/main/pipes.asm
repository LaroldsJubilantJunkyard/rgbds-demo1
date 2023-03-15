

 DEF PIPES_BYTE_COUNT EQU 4
 DEF PIPES_COUNT EQU 4
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
    cp a, 5
    ret z

    IncreaseAddress wCurrentPipeAddress, PIPES_BYTE_COUNT

UpdatePipesLoop:

    LoadAddressIntoHL wCurrentPipeAddress, 0
    
    ld a, [hli]
    cp a, PIPE_VISIBLE

    jp nz, UpdateNextPipe

    ; Get our x position low byte  (and increment)
    ld a, [hli]
    ld c, a ; save the low byte in c

    ; Get our high byte
    ld a, [hl]
    sub a, HORIZONTAL_MOVE_SPEED ; apply motion
    ld b, a ; save high byte in b
    ld a, c ; re-retrieve our low byte
    sbc a, 0 ; apply the carry over and update
    ld c, a

    ; re-update the values
    ld a, b
    ld [hld], a
    ld a, c
    ld [hli], a

    inc [hl]

    ; Get the actual value
    srl b
    rr c
    srl b
    rr c
    srl b
    rr c
    srl b
    rr c

    ld a, [hl]
    cp a, TOP_PIPE

    jp nz, DrawBottom

DrawTop:

    ; y = 16 ( taking into consideration the negative 16 offset)
	ld a, 16
	ld [wDrawMetasprites_MetaspritePosition.y], a

    jp DrawX

DrawBottom:

    ; y = 160 ( taking into consideration the negative 16 offset)
	ld a, 160
	ld [wDrawMetasprites_MetaspritePosition.y], a

DrawX:
	ld a, c
	ld [wDrawMetasprites_MetaspritePosition.x], a

    LoadMetaspriteAddressAndDraw wTopPipe1

    jp UpdateNextPipe


wTopPipe1:
    .count db 6
    .row1a db 0, 0, 0 ,0
    .row1b db 0, 8, 0 ,0
    .row2a db 8, -8, 0 ,0
    .row2b db 0, 8, 0 ,0
    .row3a db 8, -8, 0 ,0
    .row3b db 0, 8, 0 ,0