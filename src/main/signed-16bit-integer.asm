
SECTION "Signed16BitIntegerVariables", WRAM0

mChangeSign: db
mChangeValue: db
mNewLow: db
mNewHigh: db
mLowCarry:db
mHighCarry:db
mAddressOfTarget16BitInteger: dw

SECTION "Signed16BitInteger", ROM0

;IncreaseValue myPointer, myOtherPointer
MACRO Change16BitValue_By_16BitValue


    ; save these values
    push hl
    push bc
    push de

    ; load scaled low byte of other value in b
    ; load scaled high byte of other value in c
    ld hl, \2
    ld a, [hli]
    ld b, a
    ld a, [hl]

    ; Save the high byte in c & d
    ; c will be unscaled
    ld c, a
    ld d, a

    ; Remove the sign
    ld a, c
    and a,%01111111
    ld c, a

    ; unscale
    srl c
    rr b
    srl c
    rr b
    srl c
    rr b
    srl c
    rr b

    ; Save the value we want to change by in our RAM variable
    ld a, b
    ld [mChangeValue],a

    ; get our high byte
    ld a, d

    call SetChangeSignFromDsMSB

    IncreaseOrDecrease16BitValue \1, 

    ; restore these values
    pop de
    pop bc
    pop hl

    ENDM

SetChangeSignFromDsMSB:

    ; get the MSB of our high byte
    bit 7, d

    jp z, SetChangeSignFromDsMSB_Zero

SetChangeSignFromDsMSB_One:

    ld a, 1
    ld [mChangeSign], a

    ret
SetChangeSignFromDsMSB_Zero:

    ld a, 0
    ld [mChangeSign], a

    ret



;IncreaseValue myPointer, r8 (amount)
MACRO Increase16BitValue_N8


    ; save these values
    push hl
    push bc
    push de

    ; Save the value we want to change by in our RAM variable
    ld a, \2
    ld [mChangeValue],a

    ld a, 0
    ld [mChangeSign], a

    IncreaseOrDecrease16BitValue \1

    ; restore these values
    pop de
    pop bc
    pop hl

    ENDM


;DecreaseValue myPointer, r8 (amount)
MACRO Decrease16BitValue_N8


    ; save these values
    push hl
    push bc
    push de

    ; Save the value we want to change by in our RAM variable
    ld a, \2
    ld [mChangeValue],a

    ld a, 1
    ld [mChangeSign], a

    IncreaseOrDecrease16BitValue \1

    ; restore these values
    pop de
    pop bc
    pop hl

    ENDM

;Decrease Value myPointer, r8 (amount)
MACRO IncreaseOrDecrease16BitValue

    ; Save the address of our integer in our two RAM variables
    ld hl, \1
    ld a, l
    ld [mAddressOfTarget16BitInteger+0], a
    ld a, h
    ld [mAddressOfTarget16BitInteger+1], a

    ; Get the low byte 
    ; get the high byte 
    ld a, [\1+0]
    ld [mNewLow], a
    ld a, [\1+1]
    ld [mNewHigh], a

    call IncreaseDecrease16BitValue 

    ; Update our values in the pointer given
    ld a, [mAddressOfTarget16BitInteger+0]
    ld l, a
    ld a, [mAddressOfTarget16BitInteger+1]
    ld h, a
    ld a, [mNewLow]
    ld [hli],a
    ld a, [mNewHigh]
    ld [hl],a

    ENDM



IncreaseDecrease16BitValue:

    ld a, [mChangeSign]
    add a, 0

    jp z, IncreaseDecrease16BitValue_IncreaseOverallValue
    jp IncreaseDecrease16BitValue_DecreaseOverallValue

IncreaseDecrease16BitValue_DecreaseOverallValue:

    ; Check the MSB in our high byte
    ld a, [mNewHigh]
    bit 7, a

    ; If it's not zero. It's negative. Increase our value
    jp nz, MoveAwayFromZero

    ; if it's zero. It's positive. decrease our value
    jp MoveTowardsZero
    

IncreaseDecrease16BitValue_IncreaseOverallValue:

    ; Check the MSB in our high byte
    ld a, [mNewHigh]
    bit 7, a

    ; If it's  zero. It's positive. Increase our value
    jp z, MoveAwayFromZero

    ; if it's NOT zero. It's negative. decrease our value
    jp MoveTowardsZero



MoveAwayFromZero:

    ; get our change value
    ld a, [mChangeValue]
    ld b, a
    
    ; Increase our low byte by our change value
    ld a, [mNewLow]
    add a, b
    ld [mNewLow], a

    ; Increase our high byte by the carryover
    ld a, [mNewHigh]
    adc a, 0
    ld [mNewHigh], a

    ret

MoveTowardsZero:

    ; If our change value is smaller than our low byte,
    ; Decrease normally
    ld a, [mChangeValue]
    ld b, a
    ld a, [mNewLow]
    sub a, b
    ld d, a

    jp nc, DecreaseValueFunctionNormally

    ; save our carry value in b
    ld a, 0
    adc a,0
    ld b ,a

    ; If our carry over doesn't cause a overflow when sutracted from the high byte
    ; Decrease normally
    ld a, [mNewHigh]
    and a, %01111111 ; remove the sign
    sub a, b
    ld e, a
    jp nc, DecreaseValueFunctionNormally

    ; Update our low value
    ; Our low value becomes our carry over from the initial mNewLow-mChangeValue
    ld a, b
    ld [mNewLow], a

    ; get our MSB for the high
    ld a, [mNewHigh]
    bit 7,a

    ; Set the high byte to 10000000 or 00000000
    ; whichever is opposite of it's current sign
    jp z, SetHighMSBToOne
    jp SetHighMSBToZero


DecreaseValueFunctionNormally:
    ld a, [mChangeValue]
    ld b, a

    ; decrease our low byte
    ld a, [mNewLow]
    sub a, b
    ld [mNewLow],a

    ; Save our carry over in b
    ld a, 0
    adc a, 0
    ld c, a

    ld a, [mNewHigh]
    bit 7, a

    jp z, DecreaseValueFunctionNormally_Positive
    jp DecreaseValueFunctionNormally_Negative

DecreaseValueFunctionNormally_Negative:

    ; decrease our high byte by the carry over
    ld a, [mNewHigh]
    and a, %01111111
    sub a, c
    or a, %10000000
    ld [mNewHigh],a

    ret

DecreaseValueFunctionNormally_Positive:

    ; decrease our high byte by the carry over
    ld a, [mNewHigh]
    sub a, c
    ld [mNewHigh],a

    ; end the increase and decrease
    ret

SetHighMSBToOne:

    ld a, %10000000
    ld [mNewHigh], a

    ret

SetHighMSBToZero:

    ld a, %00000000
    ld [mNewHigh], a
    
    ret

    