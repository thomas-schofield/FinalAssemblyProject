; @author	Thomas Schofield
;               Tyler Humbert
; Final Assembly Project - Seven Segment Display
; NOTE: NEED TO INVERT BIC TO ORR
;

; Setup Addresses
; Port 1
P1IN    EQU     0x40004C00
P1OUT   EQU     0x40004C02
P1DIR   EQU     0x40004C04
P1REN   EQU     0x40004C06

; Port 2
P2IN    EQU     0x40004C01
P2OUT   EQU     0x40004C03
P2DIR   EQU     0x40004C05
P2REN   EQU     0x40004C07

; Port 3
P3IN    EQU     0x40004C20
P3OUT   EQU     0x40004C22
P3DIR   EQU     0x40004C24
P3REN   EQU     0x40004C26

; Port 6
P6IN    EQU     0x40004C41
P6OUT   EQU     0x40004C43
P6DIR   EQU     0x40004C45
P6REN   EQU     0x40004C47

; General Equates
btnINC  EQU     0x02    ; Port 1.1
btnDEC  EQU     0x10    ; Port 1.4
btnROLL EQU     0x80    ; Port 3.7

; Define bits for specific segments
seg_A   EQU     0x20    ; A - P2.5
seg_B   EQU     0x80    ; B - P2.7
seg_C   EQU     0x40    ; C - P2.6
seg_D   EQU     0x10    ; D - P2.4
seg_E   EQU     0x40    ; E - P6.6
seg_F   EQU     0x80    ; F - P6.7
seg_G   EQU     0x08    ; G - P2.3

UP      EQU     0x01
DOWN    EQU     0x00

        THUMB
        AREA    |.text|, CODE, READONLY, ALIGN=2
        EXPORT  main_loop

main_loop
        ; Start the program
        BL      gpio_init

        MOV     R2, #0
        BL      state_0

loop
        ; Main loop that checks for button presses
        LDR     R0, =P1IN
        LDRB    R1, [R0]
        TST     R1, #btnINC
        BEQ     inc
        TSTNE   R1, #btnDEC
        BEQ     dec

        LDR     R0, =P3IN
        LDRB    R1, [R0]
        TST     R1, #btnROLL
        BEQ.W   roll

        B       loop
        LTORG

        MACRO
$label  NextBranch      $curr, $dir
$label  MOV     R0, $dir
        CMP     R0, #UP
        ADDEQ   $curr, $curr, #1
        SUBNE   $curr, $curr, #1
        MEND

inc     NextBranch      R2, #UP
        CMP     R2, #15
        MOVGT   R2, #0
        B	determine_state

dec     NextBranch      R2, #DOWN
        CMP     R2, #0
        MOVLT   R2, #15
        B       determine_state

roll
        MOV     R3, #1
roll_s  CMP     R2, #7
        BLE     dec
        BGT     inc
		
		B		loop

        MACRO
        SetState        $reg, $num
        CMP     $reg, #0x0$num
        BLEQ    state_$num
        BLEQ    delay
        BEQ.W   next_step

        MEND

determine_state
        SetState        R2, 0
        SetState        R2, 1
        SetState        R2, 2
        SetState        R2, 3
        SetState        R2, 4
        SetState        R2, 5
        SetState        R2, 6
        SetState        R2, 7
        SetState        R2, 8
        SetState        R2, 9
        SetState        R2, A
        SetState        R2, B
        SetState        R2, C
        SetState        R2, D
        SetState        R2, E
        SetState        R2, F

        ; If everything else fails, reset to the beginning
        MOV     R2, #0
        BL      state_0
        BL      delay
        MOV     R3, #0
        B       loop

next_step
        CMP     R3, #1
        BNE     loop
        CMPEQ   R2, #0
        BNE     roll_s
        MOVEQ   R3, #0
        BEQ     loop

        B       loop

disable_all     PROC
        ; Ensure the outputs are disabled
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_E
        BIC     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        BIC     R1, #seg_B
        BIC     R1, #seg_C
        BIC     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
	ENDP

state_0 PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_E
        BIC     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        BIC     R1, #seg_B
        BIC     R1, #seg_C
        BIC     R1, #seg_D
        ORR     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

state_1 PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        ORR     R1, #seg_E
        ORR     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        ORR     R1, #seg_A
        BIC     R1, #seg_B
        BIC     R1, #seg_C
        ORR     R1, #seg_D
        ORR     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

state_2 PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_E
        ORR     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        BIC     R1, #seg_B
        ORR     R1, #seg_C
        BIC     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

state_3 PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        ORR     R1, #seg_E
        ORR     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        BIC     R1, #seg_B
        BIC     R1, #seg_C
        BIC     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

state_4 PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        ORR     R1, #seg_E
        BIC     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        ORR     R1, #seg_A
        BIC     R1, #seg_B
        BIC     R1, #seg_C
        ORR     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

state_5 PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        ORR     R1, #seg_E
        BIC     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        ORR     R1, #seg_B
        BIC     R1, #seg_C
        BIC     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

state_6 PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_E
        BIC     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        ORR     R1, #seg_B
        BIC     R1, #seg_C
        BIC     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

state_7 PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        ORR     R1, #seg_E
        ORR     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        BIC     R1, #seg_B
        BIC     R1, #seg_C
        ORR     R1, #seg_D
        ORR     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

state_8 PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_E
        BIC     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        BIC     R1, #seg_B
        BIC     R1, #seg_C
        BIC     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

state_9 PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        ORR     R1, #seg_E
        BIC     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        BIC     R1, #seg_B
        BIC     R1, #seg_C
        ORR     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

state_A PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_E
        BIC     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        BIC     R1, #seg_B
        BIC     R1, #seg_C
        ORR     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP


state_B PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_E
        BIC     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        ORR     R1, #seg_A
        ORR     R1, #seg_B
        BIC     R1, #seg_C
        BIC     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

state_C PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_E
        BIC     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        ORR     R1, #seg_B
        ORR     R1, #seg_C
        BIC     R1, #seg_D
        ORR     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

state_D PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_E
        ORR     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        ORR     R1, #seg_A
        BIC     R1, #seg_B
        BIC     R1, #seg_C
        BIC     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

state_E PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_E
        BIC     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        ORR     R1, #seg_B
        ORR     R1, #seg_C
        BIC     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

state_F PROC
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_E
        BIC     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        ORR     R1, #seg_B
        ORR     R1, #seg_C
        ORR     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        BX      LR
        ENDP

delay   PROC
        LDR     R5, =500000
L1      SUBS    R5, #1  ; Subtract 1 from delay counter
        BNE     L1      ; Loop if the value is not equal to zero
        BX      LR      ; Return to the normal program if it is equal to zero
        ENDP

gpio_init       PROC
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Setup buttons for the three inputs
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Make P1.1 and P1.4 Inputs
        LDR     R0, =P1DIR
        LDRB    R1, [R0]
        BIC     R1, #0x12        ; P1.1 & P1.4 inputs
        STRB    R1, [R0]

        LDR     R0, =P1REN
        LDRB    R1, [R0]
        ORR     R1, #btnINC
        ORR     R1, #btnDEC
        STRB    R1, [R0]

        LDR     R0, =P1OUT
        LDRB    R1, [R0]
        ORR     R1, #btnINC
        ORR     R1, #btnDEC
        STRB    R1, [R0]

        ; P3.7 - Roll button
        LDR     R0, =P3DIR
        LDRB    R1, [R0]
        BIC     R1, #btnROLL
        STRB    R1, [R0]

        LDR     R0, =P3REN
        LDRB    R1, [R0]
        ORR     R1, #btnROLL
        STRB    R1, [R0]

        LDR     R0, =P3OUT
        LDRB    R1, [R0]
        ORR     R1, #btnROLL
        STRB    R1, [R0]

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Setup the seven outputs
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; Use P2.(7, 6, 5, 4, 3)
        ; Make the pins outputs
        LDR     R0, =P2DIR
        LDRB    R1, [R0]
        ORR     R1, #seg_A
        ORR     R1, #seg_B
        ORR     R1, #seg_C
        ORR     R1, #seg_D
        ORR     R1, #seg_G
        STRB    R1, [R0]

        ; Make sure the pull up resistors are disabled
        LDR     R0, =P2REN
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        BIC     R1, #seg_B
        BIC     R1, #seg_C
        BIC     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        ; Ensure the outputs are disabled
        LDR     R0, =P2OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_A
        BIC     R1, #seg_B
        BIC     R1, #seg_C
        BIC     R1, #seg_D
        BIC     R1, #seg_G
        STRB    R1, [R0]

        ; Setup P6
        LDR     R0, =P6DIR
        LDRB    R1, [R0]
        ORR     R1, #seg_E
        ORR     R1, #seg_F
        STRB    R1, [R0]

        LDR     R0, =P6REN
        LDRB    R1, [R0]
        ORR     R1, #seg_E
        ORR     R1, #seg_F
        STRB    R1, [R0]

        ; Ensure the outputs are disabled
        LDR     R0, =P6OUT
        LDRB    R1, [R0]
        BIC     R1, #seg_E
        BIC     R1, #seg_F
        STRB    R1, [R0]

        BX      LR
        ENDP

        END
