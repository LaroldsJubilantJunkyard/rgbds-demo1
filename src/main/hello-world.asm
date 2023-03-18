INCLUDE "src/main/hardware.inc"
include "src/main/happy-face.z80"
include "src/main/happy-face.inc"
include "src/main/metasprites.asm"
include "src/main/signed-16bit-integer.asm"
include "src/main/player.asm"
include "src/main/input.asm"
include "src/main/math.inc"
include "src/main/pipes.asm"
include "src/main/grid-movement.asm"
include "src/main/background.asm"
include "src/main/tilemap.inc"
include "src/main/sprites.inc"

DEF HORIZONTAL_MOVE_SPEED EQU 8
DEF GRAVITY_SPEED EQU 2
DEF MAX_SPEED EQU 250
DEF JUMP_SPEED EQU 250


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

	ld a, 0
	ld [wGameState], a

	call InitializeBackground
	call InitializePlayer
	;call InitPipes

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
	jp nc, ActiveLoop

	call UpdateCameraPosition;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	jp Loop

ActiveLoop:

    call ResetNextOAMSpriteAddress
	
	call ScrollBackground
	call UpdatePlayer
	;call UpdatePipes

	jp Loop


SECTION "GameVariables", WRAM0

wLastKeys: db
wCurKeys: db
wNewKeys: db

wGameState: db
