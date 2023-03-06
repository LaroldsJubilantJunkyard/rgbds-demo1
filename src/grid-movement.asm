
 SECTION "GridMovement", ROM0

StartMoveDown_UsingFromStack_Direction:

	ld a, [hl]
	cp a, 0
	ret nz

	ld a, 2
	ld [hl], a

	ret

StartMoveUp_UsingFromStack_Direction:



	ld a, [hl]
	cp a, 0
	ret nz

	ld a, 4
	ld [hl], a

	ret

StartMoveRight_UsingFromStack_Direction:


	ld a, [hl]
	cp a, 0
	ret nz

	ld a, 1
	ld [hl],a

	ret

StartMoveLeft_UsingFromStack_Direction:


	ld a, [hl]
	cp a, 0
	ret nz

	ld a, 3
	ld [hl], a

	ret

MACRO LOAD_POSITION_INTO_A
	ld a, [bc] 
ENDM

MACRO UPDATE_POSITION_WITH_A
	ld [bc], a 
ENDM

MACRO LOAD_Y_POSITION_INTO_A
	PUSH hl
	PUSH bc
	POP hl

	inc hl

	ld a, [hl]

	pop hl

ENDM

MACRO UPDATE_Y_POSITION_WITH_A


	PUSH hl
	PUSH bc
	push de
	PUSH bc
	POP hl

	ld b, a

	inc hl
	ld a, b
	ld [hl], a

	pop de
	pop bc
	pop hl

ENDM

MACRO LOAD_STEP_INTO_A
	ld a, [de]
ENDM
MACRO UPDATE_STEP_WITH_A
	ld [de], a
ENDM
MACRO LOAD_DIRECTION_INTO_A
	ld a, [hl]
ENDM
MACRO UPDATE_DIRECTION_WITH_A
	ld [hl], a
ENDM


	
UpdateSprite1Position:

	push hl
	push bc
	pop hl

	ld a, [hli]
	add a
	add a
	add a
	ld c, a
	ld a, [hl]
	add a
	add a
	add a
	ld b, a

	pop hl

	push bc
	push de

	ld a, 0
	ld d, a

	jp 	SetInOAM_Horizontal_BC_On_Stack_DE_On_Stack


IncreasePlayerStep_PositionStepDirection:

	; Inrease our value by 2
	LOAD_STEP_INTO_A
	add a, 2
	UPDATE_STEP_WITH_A

	; Compare our step against 128 (8*16)
	LOAD_STEP_INTO_A
	sub a, 128

	; if our player step is NOT over 128
	; Position our player accordingly
	jp c, PositionPlayerForStep

	; reset our step 
	ld a, 0
	UPDATE_STEP_WITH_A

	LOAD_DIRECTION_INTO_A
	cp a, 2
	jp z, MoveOneDown

	LOAD_DIRECTION_INTO_A
	cp a, 3
	jp z, MoveOneLeft

	LOAD_DIRECTION_INTO_A
	cp a, 4
	jp z, MoveOneUp

	LOAD_DIRECTION_INTO_A
	cp a, 1
	jp z, MoveOneRight

	
	jp PositionPlayerForStep
	
MoveOneRight:


	LOAD_POSITION_INTO_A
	inc a
	UPDATE_POSITION_WITH_A


	ld a,0
	UPDATE_DIRECTION_WITH_A

	jp PositionPlayerForStep

MoveOneDown:

	LOAD_Y_POSITION_INTO_A
	inc a
	UPDATE_Y_POSITION_WITH_A

	ld a,0
	UPDATE_DIRECTION_WITH_A


	jp PositionPlayerForStep

MoveOneUp:

	LOAD_Y_POSITION_INTO_A
	dec a
	UPDATE_Y_POSITION_WITH_A

	ld a,0
	UPDATE_DIRECTION_WITH_A


	jp PositionPlayerForStep
MoveOneLeft:

	LOAD_POSITION_INTO_A
	dec a
	UPDATE_POSITION_WITH_A

	ld a,0
	UPDATE_DIRECTION_WITH_A


	jp PositionPlayerForStep

PositionPlayerForStep:

	LOAD_DIRECTION_INTO_A
	cp a, 0
	jp z, PositionPlayerXForStep
	cp a, 1
	jp z, PositionPlayerXForStep
	cp a, 3
	jp z, PositionPlayerXForStep

PositionPlayerYForStep:

	push bc
	push hl
	push bc
	pop hl
	
	; get our x position in a
	ld a, [hli]

	; multiply by 8 by addding to itself 3 times per:
	; https://github.com/tbsp/simple-gb-asm-examples/blob/master/src/grid-collision/grid-collision.asm
	add a
	add a
	add a

	;; save our x position in b
	ld b, a

	; Get our grid y position in a
	ld a, [hld]

	; multiply by 8 by addding to itself 3 times per:
	; https://github.com/tbsp/simple-gb-asm-examples/blob/master/src/grid-collision/grid-collision.asm
	add a
	add a
	add a

	; Save our primary axis position in c
	ld c, a

	;;Restore value of hl
	pop hl

	; x should be in b, and y should be in a, bc is on the stack
	jp PositionPlayerMultply_BC_On_Stack

PositionPlayerXForStep:

	; Save bc (pointer to position), because we are going to be using b & c
	push bc
	push hl
	push bc
	pop hl

	; Get the y position in a
	ld a, [hli]
	ld a, [hld]

	; multiply by 8 by addding to itself 3 times per:
	; https://github.com/tbsp/simple-gb-asm-examples/blob/master/src/grid-collision/grid-collision.asm
	add a
	add a
	add a

	;; Save our y position in b
	ld b, a

	; Get our grid x position
	ld a, [hl]

	; multiply by 8 by addding to itself 3 times per:
	; https://github.com/tbsp/simple-gb-asm-examples/blob/master/src/grid-collision/grid-collision.asm
	add a
	add a
	add a

	; Save our primary axis position in c
	ld c, a

	pop hl

	; x should be in c, and y should be in b, bc is on the stack
	jp PositionPlayerMultply_BC_On_Stack
	
PositionPlayerMultply_BC_On_Stack:

	; Get our step and shift left 4 times
	LOAD_STEP_INTO_A
	srl a
	srl a
	srl a
	srl a

	push de

	; c is our primary axis
	; b is our secondary axis
	; Our scaled step alone is in d
	ld d, a

	LOAD_DIRECTION_INTO_A
	cp a, 1
	jp z, IncreaseCByD_Horizontal_BC_On_Stack_DE_On_Stack
	cp a, 2
	jp z, IncreaseCByD_Vertical_BC_On_Stack_DE_On_Stack
	cp a, 3
	jp z, DecreaseCByD_Horizontal_BC_On_Stack_DE_On_Stack
	cp a, 4
	jp z, DecreaseCByD_Vertical_BC_On_Stack_DE_On_Stack

	jp SetInOAM_Horizontal_BC_On_Stack_DE_On_Stack

DecreaseCByD_Vertical_BC_On_Stack_DE_On_Stack:

	; decrease our primary axis
	ld a, c
	sub a, d
	ld c, a

	jp SetInOAM_Vertical_BC_On_Stack_DE_On_Stack

IncreaseCByD_Vertical_BC_On_Stack_DE_On_Stack:

	; nincrease our primary axis
	ld a, c
	add a, d
	ld c, a

 	jp SetInOAM_Vertical_BC_On_Stack_DE_On_Stack

DecreaseCByD_Horizontal_BC_On_Stack_DE_On_Stack:

	; decrease our primary axis
	ld a, c
	sub a,d
	ld c, a

	jp SetInOAM_Horizontal_BC_On_Stack_DE_On_Stack

IncreaseCByD_Horizontal_BC_On_Stack_DE_On_Stack:

	; nincrease our primary axis
	ld a,c
	add a,d
	ld c, a

 	jp SetInOAM_Horizontal_BC_On_Stack_DE_On_Stack
	
SetInOAM_Horizontal_BC_On_Stack_DE_On_Stack:

; c is our primary axis position
; b is our secondary axis position
; d is our step

	push hl

	ld a, c
 	ld hl, _OAMRAM+1
    ld [hl], a

	
	ld a, b
 	ld hl, _OAMRAM+0
    ld [hl], a

	pop hl
	pop de
	pop bc 
	ret

SetInOAM_Vertical_BC_On_Stack_DE_On_Stack:

; c is our primary axis position
; b is our secondary axis position
; d is our step

	push hl

	ld a, c
 	ld hl, _OAMRAM+0
    ld [hl], a

	
	ld a, b
 	ld hl, _OAMRAM+1
    ld [hl], a

	pop hl
	pop de
	pop bc 
	ret