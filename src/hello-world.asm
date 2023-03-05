INCLUDE "src/hardware.inc"
include "src/happy-face.z80"
include "src/happy-face.inc"
include "src/input.asm"


SECTION "Header", ROM0[$100]

	jp EntryPoint

	ds $150 - @, 0 ; Make room for the header

EntryPoint:
	; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a

	; Do not turn the LCD off outside of VBlank
WaitVBlank:
	ld a, [rLY] ; Copy the vertical line to a
	cp 144 ; Check if the vertical line (in a) is 0
	jp c, WaitVBlank ; A conditional jump. The condition is that 'c' is set, the last operation overflowed

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a

	; Copy the tile data
	ld de, Tiles ; de contains the address where data will be copied from;
	ld hl, $9000 ; hl contains the address where data will be copied to;
	ld bc, TilesEnd - Tiles ; bc contains how many bytes we have to copy.
CopyTiles: 
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyTiles ; Jump to COpyTiles, if the z flag is not set. (the last operation had a non zero result)

	; Copy the tilemap
	ld de, Tilemap
	ld hl, $9800
	ld bc, TilemapEnd - Tilemap
CopyTilemap:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyTilemap

	ld de, HappyFace
	ld hl, $8000
	ld bc, HappyFaceEnd - HappyFace
CopyHappyFace:

	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyHappyFace


ClearOam:
	 
	; Start clearing oam
	ld a, 0
    ld b, 160 ; 40 sprites times 4 bytes per sprite
    ld hl, _OAMRAM ; The start of our oam sprites in RAM
ClearOamLoop:
    ld [hli], a
    dec b
    jp nz, ClearOamLoop



	ld hl, _OAMRAM
	ld a, 40+16
	ld [hli], a
	ld a, 80+8
	ld [hli], a
	ld a, 0 ; Use tile zero
	ld [hli], a
	ld [hl], a


	ld hl, _OAMRAM+4
	ld a, 120+16
	ld [hli], a
	ld a, 80+8
	ld [hli], a
	ld a, 0 ; Use tile zero
	ld [hli], a
	ld [hl], a

	ld a, 0
	ld [wBallPosition+1] , a
	ld a, 5
	ld [wBallPosition+0] , a
	ld a, 0
	ld [wBallPosition+3] , a
	ld a, 2
	ld [wBallPosition+2] , a

	ld a, 0
	ld [wBallPosition2+1] , a
	ld a, 5
	ld [wBallPosition2+0] , a
	ld a, 0
	ld [wBallPosition2+3] , a
	ld a, 7
	ld [wBallPosition2+2] , a

	ld hl, wBallPosition
	ld b, 0
	call Update_SpriteB_XPosition_ToValuePointedToByHL
	
	ld hl, wBallPosition+2
	ld b, 1
	call Update_SpriteB_YPosition_ToValuePointedToByHL

	; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
	ld [rLCDC], a

	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a
    ld a, %11100100
	ld [rOBP0], a

	
Loop:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Wait until a vertical blank
	ld a, [rLY] ; Copy the vertical line to a
	cp 144 ; Check if the vertical line (in a) is 0
	jp c, Loop
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    ; Check the current keys every frame and move left or right.
	; This is in input.asm
	; It's straight from: https://gbdev.io/gb-asm-tutorial/part2/input.html
	; In their words (paraphrased): reading player input for gameboy is NOT a trivial task
	; So it's best to use some tested code
    call Input

	ld a, [wCurKeys]
	and a, PADF_RIGHT
	call nz, MoveRight

	ld a, [wCurKeys]
	and a, PADF_LEFT
	call nz, MoveLeft

	ld a, [wCurKeys]
	and a, PADF_DOWN
	call nz, MoveDown

	ld a, [wCurKeys]
	and a, PADF_UP
	call nz, MoveUp

	; Move sprite 1 downward by 1

	ld hl, wBallPosition2
	ld b, 1
	call IncreaseTwoBytes_PointedToByHL_ByB

	ld b,1 ; which sprite
	call Update_SpriteB_XPosition_ToValuePointedToByHL


	jp Loop

MoveDown:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Increase the x position of the ball ;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld hl, wBallPosition+2
	ld b,5 ; move speed
	call IncreaseTwoBytes_PointedToByHL_ByB

	ld b,0 ; which sprite
	call Update_SpriteB_YPosition_ToValuePointedToByHL
	ret

MoveUp:

	ld hl, wBallPosition+2
	ld b,5 ; move speed
	call DecreaseTwoBytes_PointedToByHL_ByB


	ld b,0 ; which sprite
	call Update_SpriteB_YPosition_ToValuePointedToByHL

	ret

MoveRight:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Increase the x position of the ball ;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ld hl, wBallPosition
	ld b,5 ; move speed
	call IncreaseTwoBytes_PointedToByHL_ByB

	ld b,0 ; which sprite
	call Update_SpriteB_XPosition_ToValuePointedToByHL
	ret

MoveLeft:

	ld hl, wBallPosition
	ld b,5 ; move speed
	call DecreaseTwoBytes_PointedToByHL_ByB

	
	ld b,0 ; which sprite
	call Update_SpriteB_XPosition_ToValuePointedToByHL

	ret

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



SECTION "Tile data", ROM0

Tiles:
	db $00,$ff, $00,$ff, $00,$ff, $00,$ff, $00,$ff, $00,$ff, $00,$ff, $00,$ff
	db $00,$ff, $00,$80, $00,$80, $00,$80, $00,$80, $00,$80, $00,$80, $00,$80
	db $00,$ff, $00,$7e, $00,$7e, $00,$7e, $00,$7e, $00,$7e, $00,$7e, $00,$7e
	db $00,$ff, $00,$01, $00,$01, $00,$01, $00,$01, $00,$01, $00,$01, $00,$01
	db $00,$ff, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00
	db $00,$ff, $00,$7f, $00,$7f, $00,$7f, $00,$7f, $00,$7f, $00,$7f, $00,$7f
	db $00,$ff, $03,$fc, $00,$f8, $00,$f0, $00,$e0, $20,$c0, $00,$c0, $40,$80
	db $00,$ff, $c0,$3f, $00,$1f, $00,$0f, $00,$07, $04,$03, $00,$03, $02,$01
	db $00,$80, $00,$80, $7f,$80, $00,$80, $00,$80, $7f,$80, $7f,$80, $00,$80
	db $00,$7e, $2a,$7e, $d5,$7e, $2a,$7e, $54,$7e, $ff,$00, $ff,$00, $00,$00
	db $00,$01, $00,$01, $ff,$01, $00,$01, $01,$01, $fe,$01, $ff,$01, $00,$01
	db $00,$80, $80,$80, $7f,$80, $80,$80, $00,$80, $ff,$80, $7f,$80, $80,$80
	db $00,$7f, $2a,$7f, $d5,$7f, $2a,$7f, $55,$7f, $ff,$00, $ff,$00, $00,$00
	db $00,$ff, $aa,$ff, $55,$ff, $aa,$ff, $55,$ff, $fa,$07, $fd,$07, $02,$07
	db $00,$7f, $2a,$7f, $d5,$7f, $2a,$7f, $55,$7f, $aa,$7f, $d5,$7f, $2a,$7f
	db $00,$ff, $80,$ff, $00,$ff, $80,$ff, $00,$ff, $80,$ff, $00,$ff, $80,$ff
	db $40,$80, $00,$80, $7f,$80, $00,$80, $00,$80, $7f,$80, $7f,$80, $00,$80
	db $00,$3c, $02,$7e, $85,$7e, $0a,$7e, $14,$7e, $ab,$7e, $95,$7e, $2a,$7e
	db $02,$01, $00,$01, $ff,$01, $00,$01, $01,$01, $fe,$01, $ff,$01, $00,$01
	db $00,$ff, $80,$ff, $50,$ff, $a8,$ff, $50,$ff, $a8,$ff, $54,$ff, $a8,$ff
	db $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80
	db $ff,$00, $ff,$00, $ff,$00, $ab,$7e, $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e
	db $ff,$01, $fe,$01, $ff,$01, $fe,$01, $ff,$01, $fe,$01, $ff,$01, $fe,$01
	db $7f,$80, $ff,$80, $7f,$80, $ff,$80, $7f,$80, $ff,$80, $7f,$80, $ff,$80
	db $ff,$00, $ff,$00, $ff,$00, $aa,$7f, $d5,$7f, $aa,$7f, $d5,$7f, $aa,$7f
	db $f8,$07, $f8,$07, $f8,$07, $80,$ff, $00,$ff, $aa,$ff, $55,$ff, $aa,$ff
	db $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $ff,$80, $7f,$80, $ff,$80
	db $d5,$7f, $aa,$7f, $d5,$7f, $aa,$7f, $d5,$7f, $aa,$7f, $d5,$7f, $aa,$7f
	db $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e, $d5,$7e, $eb,$3c
	db $54,$ff, $aa,$ff, $54,$ff, $aa,$ff, $54,$ff, $aa,$ff, $54,$ff, $aa,$ff
	db $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $00,$ff
	db $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e, $d5,$7e, $2a,$ff
	db $ff,$01, $fe,$01, $ff,$01, $fe,$01, $ff,$01, $fe,$01, $ff,$01, $80,$ff
	db $7f,$80, $ff,$80, $7f,$80, $ff,$80, $7f,$80, $ff,$80, $7f,$80, $aa,$ff
	db $ff,$00, $ff,$00, $ff,$00, $ff,$00, $ff,$00, $ff,$00, $ff,$00, $2a,$ff
	db $ff,$01, $fe,$01, $ff,$01, $fe,$01, $fe,$01, $fe,$01, $fe,$01, $80,$ff
	db $7f,$80, $ff,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $7f,$80, $00,$ff
	db $fe,$01, $fe,$01, $fe,$01, $fe,$01, $fe,$01, $fe,$01, $fe,$01, $80,$ff
	db $3f,$c0, $3f,$c0, $3f,$c0, $1f,$e0, $1f,$e0, $0f,$f0, $03,$fc, $00,$ff
	db $fd,$03, $fc,$03, $fd,$03, $f8,$07, $f9,$07, $f0,$0f, $c1,$3f, $82,$ff
	db $55,$ff, $2a,$7e, $54,$7e, $2a,$7e, $54,$7e, $2a,$7e, $54,$7e, $00,$7e
	db $01,$ff, $00,$01, $01,$01, $00,$01, $01,$01, $00,$01, $01,$01, $00,$01
	db $54,$ff, $ae,$f8, $50,$f0, $a0,$e0, $60,$c0, $80,$c0, $40,$80, $40,$80
	db $55,$ff, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00
	db $55,$ff, $6a,$1f, $05,$0f, $02,$07, $05,$07, $02,$03, $03,$01, $02,$01
	db $54,$ff, $80,$80, $00,$80, $80,$80, $00,$80, $80,$80, $00,$80, $00,$80
	db $55,$ff, $2a,$1f, $0d,$07, $06,$03, $01,$03, $02,$01, $01,$01, $00,$01
	db $55,$ff, $2a,$7f, $55,$7f, $2a,$7f, $55,$7f, $2a,$7f, $55,$7f, $00,$7f
	db $55,$ff, $aa,$ff, $55,$ff, $aa,$ff, $55,$ff, $aa,$ff, $55,$ff, $00,$ff
	db $15,$ff, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00
	db $55,$ff, $6a,$1f, $0d,$07, $06,$03, $01,$03, $02,$01, $03,$01, $00,$01
	db $54,$ff, $a8,$ff, $54,$ff, $a8,$ff, $50,$ff, $a0,$ff, $40,$ff, $00,$ff
	db $00,$7e, $2a,$7e, $d5,$7e, $2a,$7e, $54,$7e, $ab,$76, $dd,$66, $22,$66
	db $00,$7c, $2a,$7e, $d5,$7e, $2a,$7e, $54,$7c, $ff,$00, $ff,$00, $00,$00
	db $00,$01, $00,$01, $ff,$01, $02,$01, $07,$01, $fe,$03, $fd,$07, $0a,$0f
	db $00,$7c, $2a,$7e, $d5,$7e, $2a,$7e, $54,$7e, $ab,$7e, $d5,$7e, $2a,$7e
	db $00,$ff, $a0,$ff, $50,$ff, $a8,$ff, $54,$ff, $a8,$ff, $54,$ff, $aa,$ff
	db $dd,$62, $bf,$42, $fd,$42, $bf,$40, $ff,$00, $ff,$00, $f7,$08, $ef,$18
	db $ff,$00, $ff,$00, $ff,$00, $ab,$7c, $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e
	db $f9,$07, $fc,$03, $fd,$03, $fe,$01, $ff,$01, $fe,$01, $ff,$01, $fe,$01
	db $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7e, $d5,$7e, $ab,$7c
	db $f7,$18, $eb,$1c, $d7,$3c, $eb,$3c, $d5,$3e, $ab,$7e, $d5,$7e, $2a,$ff
	db $ff,$01, $fe,$01, $ff,$01, $fe,$01, $ff,$01, $fe,$01, $ff,$01, $a2,$ff
	db $7f,$c0, $bf,$c0, $7f,$c0, $bf,$e0, $5f,$e0, $af,$f0, $57,$fc, $aa,$ff
	db $ff,$01, $fc,$03, $fd,$03, $fc,$03, $f9,$07, $f0,$0f, $c1,$3f, $82,$ff
	db $55,$ff, $2a,$ff, $55,$ff, $2a,$ff, $55,$ff, $2a,$ff, $55,$ff, $00,$ff
	db $45,$ff, $a2,$ff, $41,$ff, $82,$ff, $41,$ff, $80,$ff, $01,$ff, $00,$ff
	db $54,$ff, $aa,$ff, $54,$ff, $aa,$ff, $54,$ff, $aa,$ff, $54,$ff, $00,$ff
	db $15,$ff, $2a,$ff, $15,$ff, $0a,$ff, $15,$ff, $0a,$ff, $01,$ff, $00,$ff
	db $01,$ff, $80,$ff, $01,$ff, $80,$ff, $01,$ff, $80,$ff, $01,$ff, $00,$ff
TilesEnd:

SECTION "Tilemap", ROM0

Tilemap:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $01, $02, $03, $01, $04, $03, $01, $05, $00, $01, $05, $00, $06, $04, $07, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $08, $09, $0a, $0b, $0c, $0d, $0b, $0e, $0f, $08, $0e, $0f, $10, $11, $12, $13, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $14, $15, $16, $17, $18, $19, $1a, $1b, $0f, $14, $1b, $0f, $14, $1c, $16, $1d, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $1e, $1f, $20, $21, $22, $23, $24, $22, $25, $1e, $22, $25, $26, $22, $27, $1d, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $01, $28, $29, $2a, $2b, $2c, $2d, $2b, $2e, $2d, $2f, $30, $2d, $31, $32, $33, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $08, $34, $0a, $0b, $11, $0a, $0b, $35, $36, $0b, $0e, $0f, $08, $37, $0a, $38, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $14, $39, $16, $17, $1c, $16, $17, $3a, $3b, $17, $1b, $0f, $14, $3c, $16, $1d, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $1e, $3d, $3e, $3f, $22, $27, $21, $1f, $20, $21, $22, $25, $1e, $22, $40, $1d, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $00, $41, $42, $43, $44, $30, $33, $41, $45, $43, $41, $30, $43, $41, $30, $33, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,  0,0,0,0,0,0,0,0,0,0,0,0
TilemapEnd:


SECTION "Counter", WRAM0

; Our ball's position
; first byte is high, second is low
wBallPosition: 
	.x dw
	.y dw


; Our ball's position
; first byte is high, second is low
wBallPosition2: 
	.x dw
	.y dw

wCurKeys: db
wNewKeys: db