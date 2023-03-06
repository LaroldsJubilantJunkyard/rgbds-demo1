INCLUDE "src/hardware.inc"
include "src/happy-face.z80"
include "src/happy-face.inc"
include "src/input.asm"
include "src/math.inc"
include "src/grid-movement.asm"
include "src/tilemap.inc"
include "src/sprites.inc"


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

	ld a,0
	ld [wBallDirection], a

	ld a,0
	ld [wBallStep], a

	ld a, 05
	ld [wBallPosition+1] , a
	ld a, 5
	ld [wBallPosition+0] , a

	ld bc, wBallPosition
	ld de, wBallStep
	ld hl, wBallDirection
	call UpdateSprite1Position

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
	


	;; If we have a direction, increase our players step
	; Otherwise we want to poll for user input
	ld a, [wBallDirection]
	cp a,0
	jp z, PollForInput

	ld bc, wBallPosition
	ld de, wBallStep
	ld hl, wBallDirection
	call IncreasePlayerStep_PositionStepDirection

	jp Loop

PollForInput:

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

	jp Loop



MoveDown:

	ld hl, wBallDirection
	call StartMoveDown_UsingFromStack_Direction
	ret

MoveUp:

	ld hl, wBallDirection
	call StartMoveUp_UsingFromStack_Direction

	ret

MoveRight:

	
	ld hl, wBallDirection
	call StartMoveRight_UsingFromStack_Direction
	ret

MoveLeft:

	ld hl, wBallDirection
	call StartMoveLeft_UsingFromStack_Direction
	ret





SECTION "Counter", WRAM0

; Our ball's position
; first byte is high, second is low
wBallPosition: 
	.x db
	.y db

wBallDirection: db
wBallStep: db


; Our ball's position
; first byte is high, second is low
wBallPosition2: 
	.x dw
	.y dw

wCurKeys: db
wNewKeys: db