
 SECTION "Signed16BitInteger", ROM0



;Decrease Value myPointer, r8 (amount)
MACRO Increase16BitValue

    ; Save these values because we will use them
    push bc
    push de
    push hl


    ; save our first value in hl
    ; Save our second value in e
    ld e, \2
    ld hl, \1

    push hl

    ; Get the low byte in b,
    ; get the high byte in c
    ld a, [\1+0]
    ld b, a
    ld a, [\1+1]
    ld c, a

    CheckMSBInC  IncreaseValueFunction, DecreaseValueFunction

    ENDM


;Decrease Value myPointer, r8 (amount)
MACRO Decrease16BitValue

    ; Save these values because we will use them
    push bc
    push de
    push hl

    ; save our first value in hl
    ; Save our second value in e
    ld e, \2
    ld hl, \1

    push hl

    ; Get the low byte in b,
    ; get the high byte in c
    ld a, [\1+0]
    ld b, a

    ld a, [\1+1]
    ld c, a


    CheckMSBInC DecreaseValueFunction, IncreaseValueFunction

    ENDM

MACRO CheckMSBInC
    ld d, c

    push de

    ; Check the MSB in our high byte
    bit 7, d

    ; If it's zero. It's positive
    call z, \1

    pop de

    ; Check the MSB in our high byte
    bit 7, d

    ; If it's not zero. It's negative
    call nz, \2

    pop hl
    ; Update our values in the pointer given
    ld a, b
    ld [hli],a
    ld a, c
    ld [hl],a

    pop hl
    pop de
    pop bc

    ENDM



IncreaseValueFunction:

    ; Increase our low byte
    ld a, b
    add a, e
    ld b, a

    ; Increase our high byte by the carryover
    ld a, c
    adc a, 0
    ld c, a

    ret

DecreaseValueFunction:

    ; decrease our low byte
    ; save the carry over in d
    ld a, b
    sub a, e
    ld b,a
    ld a, 0
    adc a, 0
    ld d, a ; save our low byte carry over in d

    ; decrease our high byte by the carry over
    ; save our high byte carry over in e
    ld a, c
    sub a, d
    ld c,a
    ld a, 0
    adc a, 0
    ld e, a ; save our high byte carry over in e

    ; check our high byte carry over
    ld a, e
    cp a, 0

    ; If we have no carry over
    ; end the increase and decrease
    ret nc

    ; use our low byte carry over as our new low byte
    ld b, d

    bit 7,c
    jp z, SetHighMSBToOne
    jp SetHighMSBToZero

SetHighMSBToOne:

    ld a, %10000000
    ld c, a

    ret

SetHighMSBToZero:

    ld a, %00000000
    ld c, a
    
    ret

    