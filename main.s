; --- Registros RCC e AFIO ---
RCC_APB1ENR     EQU 0x40021000+0x1C
RCC_APB2ENR     EQU 0x40021000+0x18
AFIO_MAPR       EQU 0x40010000+0x04

; --- GPIOA ---
GPIOA_CRL       EQU 0x40010800
GPIOA_CRH       EQU 0x40010800+0x04
GPIOA_BSRR      EQU 0x40010800+0x10
GPIOA_BRR       EQU 0x40010800+0x14

; --- GPIOB ---
GPIOB_CRL       EQU 0x40010C00
GPIOB_CRH       EQU 0x40010C00+0x04
GPIOB_BSRR      EQU 0x40010C00+0x10
GPIOB_BRR       EQU 0x40010C00+0x14

        ; --- Timer 2 ---
TIM2_ARR        EQU 0x40000000+0x2C
TIM2_SR         EQU 0x40000000+0x10
TIM2_CR1        EQU 0x40000000+0x00
TIM2_PSC        EQU 0x40000000+0x28

        ; --- Máscaras ---
hab_gpiob_gpioa_afio EQU 0x0D
JTAG_GPIO            EQU 0x02000000

        EXPORT __main

        AREA    ARR_TABLE, DATA, READONLY
arr_lookup_table
        DCW 0, 0, 0, 0, 0
        DCW 13759         ; Tecla 5 (C)
        DCW 12258         ; Tecla 6 (D)
        DCW 10920         ; Tecla 7 (E)
        DCW 10307         ; Tecla 8 (F)
        DCW 9183          ; Tecla 9 (G)
        DCW 8181          ; Tecla 10 (A)
        DCW 7288          ; Tecla 11 (B)
        DCW 0
        DCW 12987         ; Tecla 13 (C#)
        DCW 11570         ; Tecla 14 (D#)
        DCW 9729          ; Tecla 15 (F#)
        DCW 8667          ; Tecla 16 (G#)
        DCW 7722          ; Tecla 17 (A#)

        AREA    atv2_code, CODE, READONLY
__main
        LDR R1, =RCC_APB2ENR
        LDR R0, [R1]
        ORR R0, R0, #hab_gpiob_gpioa_afio
        STR R0, [R1]

        LDR R1, =RCC_APB1ENR
        LDR R0, [R1]
        ORR R0, R0, #0x01
        STR R0, [R1]

        LDR R1, =AFIO_MAPR
        LDR R0, =JTAG_GPIO
        STR R0, [R1]

        ; --- Configuração GPIOA ---
        LDR R1, =GPIOA_CRL
        LDR R0, =0x43344333
        STR R0, [R1]

        LDR R1, =GPIOA_CRH
        LDR R0, =0x34433443
        STR R0, [R1]

        ; --- Configuração GPIOB ---
        LDR R1, =GPIOB_CRL
        LDR R0, [R1]
        BIC R0, R0, #(0xF << 0)
        ORR R0, R0, #0x3
        STR R0, [R1]

        LDR R1, =GPIOB_CRH
        LDR R0, =0x44444444
        STR R0, [R1]

        ; --- Timer 2 Prescaler ---
        LDR R0, =TIM2_PSC
        LDR R4, =7199
        STR R4, [R0]

        LDR R0, =TIM2_CR1
        MOV R4, #0x01
        STR R4, [R0]

main_loop
        LDR R0, =10
        BL  arr_cfg

        LDR R1, =GPIOB_BSRR
        MOV R2, #(1 << 0)
        STR R2, [R1]

        BL  delay_tim

        LDR R1, =GPIOB_BRR
        MOV R2, #(1 << 0)
        STR R2, [R1]

        BL  delay_tim
        B   main_loop

; -----------------------------------------
; Sub-rotina arr_cfg
; -----------------------------------------
arr_cfg
        PUSH {R1, R2, LR}
        LDR R1, =arr_lookup_table
        LDRH R2, [R1, R0, LSL #1]
        LDR R1, =TIM2_ARR
        STR R2, [R1]
        POP {R1, R2, PC}

; -----------------------------------------
; Sub-rotina delay_tim
; -----------------------------------------
delay_tim
        PUSH {R2, R4, LR}
        LDR R2, =TIM2_SR
        MOV R4, #0x00
        STR R4, [R2]

volta_tim
        LDR R4, [R2]
        TST R4, #0x01
        BEQ volta_tim

        POP {R2, R4, PC}

        END