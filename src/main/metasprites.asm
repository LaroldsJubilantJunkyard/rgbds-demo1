

SECTION "MetaspriteVariables", WRAM0

wMetaspriteTotalSpriteCount: db
wMetaspriteDataAddress: dw
wOAMSpriteAddress: dw

; 
wDrawMetasprites_TotalSpriteCounter: db
wDrawMetasprites_MetaspritePosition:
    .y: db
    .x: db


SECTION "Metasprites", ROM0

MACRO SaveBInOAM
     ; Load the address of the current oam sprite byte into hl
    ld a, [wOAMSpriteAddress+0]
    add a, \1
    ld l, a
    ld a, [wOAMSpriteAddress+1]
    adc a,0
    ld h, a
    ld [hl], b
    ENDM


MACRO LoadAddressIntoHL

     ld a, [\1+0]
     add a, \2
    ld l, a
    ld a, [\1+1]
    adc a, 0
    ld h, a

    ENDM

MACRO DecreaseAddress

    
    ; Decrese the metasprite data address by one
    ; The irst byte will always bee the total sprite counter
    ld a, [\1+0]
    sub a, \2
    ld [\1+0], a
    ld a, [\1+1]
    sbc a, 0
    ld [\1+1], a

    ENDM


MACRO IncreaseAddress

    
    ; Increse the metasprite data address by one
    ; The irst byte will always bee the total sprite counter
    ld a, [\1+0]
    add a, \2
    ld [\1+0], a
    ld a, [\1+1]
    adc a, 0
    ld [\1+1], a

    ENDM

MACRO LoadMetaspriteAddressAndDraw

    ld hl, \1
	ld a, l
	ld [wMetaspriteDataAddress+0], a
	ld a,h
	ld [wMetaspriteDataAddress+1], a

	call DrawMetasprites


    ENDM

ResetNextOAMSpriteAddress:

    ld hl, _OAMRAM

    ; Get the address of the first oam byte in hl
    ld a, l
    ld [wOAMSpriteAddress+0], a
    ld a, h
    ld [wOAMSpriteAddress+1], a
    ret



DrawMetasprites:


    LoadAddressIntoHL wMetaspriteDataAddress,0

    ; Reset our sprite counter
    ; The first byte p
    ld a, [hl]
    ld [wDrawMetasprites_TotalSpriteCounter], a


    ; Increse the metasprite data address by one
    ; The irst byte will always bee the total sprite counter
    IncreaseAddress wMetaspriteDataAddress, 1


DrawMetaspritesLoop:

DrawMetaspritesLoopY:


    LoadAddressIntoHL wMetaspriteDataAddress,0

    ; add the value pointed to by hl (the value in our metasprite data address) to wDrawMetasprites_MetaspritePosition
    ; update metasprite position
    ld a, [hl]
    ld b, a
    ld a, [wDrawMetasprites_MetaspritePosition.y]
    add a, b
    ld [wDrawMetasprites_MetaspritePosition.y], a

    ; Save a in b temporarily
    ld b, a

    SaveBInOAM 0

DrawMetaspritesLoopX:

    LoadAddressIntoHL wMetaspriteDataAddress,1

    ; add the value pointed to by hl (the value in our metasprite data address) to wDrawMetasprites_MetaspritePosition
    ; update metasprite position
    ld a, [hl]
    ld b, a
    ld a, [wDrawMetasprites_MetaspritePosition.x]
    add a, b
    ld [wDrawMetasprites_MetaspritePosition.x], a

    ; Save a in b temporarily
    ld b, a

    SaveBInOAM 1

DrawMetaspritesLoopTile:

    LoadAddressIntoHL wMetaspriteDataAddress,2

    ld a, [hl]
    
    ; Save a in b temporarily
    ld b, a

    SaveBInOAM 2

MoveToNextData:

    ; Move to the next metasprite data address
    IncreaseAddress wMetaspriteDataAddress, 4

    ; Move to the next oam address
    IncreaseAddress wOAMSpriteAddress, 4

    ld a, [wDrawMetasprites_TotalSpriteCounter]
    dec a
    cp a, 0
    ld [wDrawMetasprites_TotalSpriteCounter],a

    jp nz,DrawMetaspritesLoop

    ret


