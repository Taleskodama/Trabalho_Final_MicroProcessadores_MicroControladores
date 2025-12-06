RCC_BASE        EQU 0x40021000
RCC_APB1ENR     EQU RCC_BASE+0x1C
RCC_APB2ENR     EQU RCC_BASE+0x18

AFIO_MAPR       EQU 0x40010000+0x04

GPIOA_CRL       EQU 0x40010800
GPIOA_CRH       EQU 0x40010800+0x04
GPIOA_IDR       EQU 0x40010800+0x08
GPIOA_ODR       EQU 0x40010800+0x0C
GPIOA_BSRR      EQU 0x40010800+0x10
GPIOA_BRR       EQU 0x40010800+0x14

GPIOB_CRL       EQU 0x40010C00
GPIOB_CRH       EQU 0x40010C00+0x04
GPIOB_IDR       EQU 0x40010C00+0x08
GPIOB_ODR       EQU 0x40010C00+0x0C
GPIOB_BSRR      EQU 0x40010C00+0x10
GPIOB_BRR       EQU 0x40010C00+0x14

GPIOC_CRL       EQU 0x40011000
GPIOC_CRH       EQU 0x40011000+0x04
GPIOC_IDR       EQU 0x40011000+0x08
GPIOC_ODR       EQU 0x40011000+0x0C
GPIOC_BSRR      EQU 0x40011000+0x10
GPIOC_BRR       EQU 0x40011000+0x14

LCD_EN          EQU 0x1000
LCD_RS          EQU 0x8000

ADC1_BASE       EQU 0x40012400
ADC1_SR         EQU ADC1_BASE + 0x00
ADC1_CR2        EQU ADC1_BASE + 0x08
ADC1_SQR3       EQU ADC1_BASE + 0x34
ADC1_DR         EQU ADC1_BASE + 0x4C

hab_gpiob_gpioa_afio EQU 0x0D
JTAG_GPIO            EQU 0x02000000

TIM3_BASE   EQU 0x40000400
TIM3_CR1    EQU TIM3_BASE+0x00
TIM3_CCER   EQU TIM3_BASE+0x20
TIM3_CCMR2  EQU TIM3_BASE+0x1C
TIM3_PSC    EQU TIM3_BASE+0x28
TIM3_ARR    EQU TIM3_BASE+0x2C
TIM3_CCR3   EQU TIM3_BASE+0x3C

        AREA DADOS, DATA, READONLY

PSC_TAB
        DCW 2750    ; SW5 (PB5)
        DCW 2450    ; SW6 (PB4)
        DCW 2183    ; SW7 (PB3)
        DCW 2060    ; SW8 (PA3)
        DCW 1835    ; SW9 (PA4)
        DCW 1635    ; SW10 (PB8)
        DCW 1456    ; SW11 (PB9)
        DCW 0       ; Sem nota
        DCW 2596    ; SW13 (PB10)
        DCW 2313    ; SW14 (PA7)
        DCW 1944    ; SW15 (PC15)
        DCW 1732    ; SW16 (PC14)
        DCW 1543    ; SW17 (PC13)

    AREA VARIAVEIS, DATA, READWRITE
OITAVA_ATUAL    DCB 0
TIMBRE_ATUAL    DCB 50
        ALIGN

        EXPORT __main
        AREA atv1, CODE, READONLY

__main
        ; Inicialização forçada das variáveis (Correção do problema do 95)
        LDR R0, =TIMBRE_ATUAL   
        MOV R1, #50             
        STRB R1, [R0]           
        
        LDR R0, =OITAVA_ATUAL   
        MOV R1, #0
        STRB R1, [R0]

        ; Habilita Clocks
        LDR R1, =RCC_APB2ENR
        LDR R0, [R1]
        ORR R0, R0, #hab_gpiob_gpioa_afio
        STR R0, [R1]

        LDR R1, =AFIO_MAPR
        LDR R0, =JTAG_GPIO
        STR R0, [R1]

        LDR R1, =RCC_APB2ENR
        LDR R0, [R1]
        ORR R0, R0, #0x10
        STR R0, [R1]

        ; Configuração GPIOA
        LDR R1, =GPIOA_CRL
        LDR R0, [R1]
        LDR R2, =0xF00FF000
        BIC R0, R0, R2
        LDR R2, =0x80088000
        ORR R0, R0, R2
        STR R0, [R1]

        LDR R1, =GPIOA_ODR
        LDR R0, [R1]
        ORR R0, R0, #0x98
        STR R0, [R1]

        ; Configuração GPIOB
        LDR R1, =GPIOB_CRL
        LDR R0, [R1]
        LDR R2, =0x00FFF000
        BIC R0, R0, R2
        LDR R2, =0x00888000
        ORR R0, R0, R2
        STR R0, [R1]

        LDR R1, =GPIOB_ODR
        LDR R0, [R1]
        ORR R0, R0, #0x38
        STR R0, [R1]

        LDR R1, =GPIOB_CRH
        LDR R0, [R1]
        LDR R2, =0x00000FFF
        BIC R0, R0, R2 
        LDR R2, =0x00000888
        ORR R0, R0, R2
        STR R0, [R1]

        LDR R1, =GPIOB_ODR
        LDR R0, [R1]
        ORR R0, R0, #0x0700
        STR R0, [R1]

        ; Configuração GPIOC
        LDR R1, =GPIOC_CRH
        LDR R0, [R1]
        BIC R0, R0, #0xFF0000
        ORR R0, R0, #0x880000
        STR R0, [R1]

        LDR R1, =GPIOC_ODR
        LDR R0, [R1]
        ORR R0, R0, #0x1000     ; Bit 12 (Substituido <<)
        ORR R0, R0, #0x2000     ; Bit 13 (Substituido <<)
        STR R0, [R1]

        ; Configuração GPIOB High (Botões Controle)
        LDR R1, =GPIOB_CRH
        LDR R0, [R1]
        LDR R2, =0xFFFF0000
        BIC R0, R0, R2
        LDR R2, =0x88880000
        ORR R0, R0, R2
        STR R0, [R1]

        LDR R1, =GPIOB_ODR
        LDR R0, [R1]
        ORR R0, R0, #0x1000     ; Bit 12 (Substituido <<)
        ORR R0, R0, #0x2000     ; Bit 13 (Substituido <<)
        ORR R0, R0, #0x4000     ; Bit 14 (Substituido <<)
        ORR R0, R0, #0x8000     ; Bit 15 (Substituido <<)
        STR R0, [R1]

        ; Configuração PWM
        LDR R1, =GPIOB_CRL
        LDR R0, [R1]
        BIC R0, R0, #0xF
        ORR R0, R0, #0xB
        STR R0, [R1]
        
        LDR R1, =RCC_APB2ENR
        LDR R0, [R1]
        ORR R0, R0, #0x0200     ; Bit 9 (Substituido <<)   
        STR R0, [R1]

        ; Configuração ADC
        LDR R1, =GPIOB_CRL
        LDR R0, [R1]
        BIC R0, R0, #0x000000F0 
        STR R0, [R1]
        
        LDR R1, =ADC1_CR2
        MOV R0, #1      
        STR R0, [R1]

        LDR R0, =0xFF
delay_adc_init
        SUBS R0, R0, #1
        BNE delay_adc_init
        
        LDR R1, =ADC1_SQR3
        MOV R0, #9      
        STR R0, [R1]

        ; Configuração Timer
        LDR R0, =RCC_APB1ENR
        LDR R1, [R0]
        ORR R1, R1, #0x02
        STR R1, [R0]

        LDR R0, =TIM3_ARR
        MOV R1, #99
        STR R1, [R0]

        LDR R0, =TIM3_CCR3
        MOV R1, #50
        STR R1, [R0]

        LDR R0, =TIM3_CCMR2
        MOV R1, #0x68
        STR R1, [R0]

loop_principal

        BL atualiza_escala_timbre
        BL identifica_tecla

        CMP R4, #0xFF
        BEQ sem_nota

        BL toca_nota
        B loop_principal

sem_nota
        LDR R0, =TIM3_CR1
        MOV R1, #0
        STR R1, [R0]

        LDR R0, =TIM3_CCER
        MOV R1, #0
        STR R1, [R0]

        B loop_principal

; ====================================================================
; SUB-ROTINA ATUALIZA ESCALA E TIMBRE
; ====================================================================
atualiza_escala_timbre
        PUSH {R0-R3, LR}

        LDR R0, =GPIOB_IDR
        LDR R1, [R0]

        ; --- Controle de Oitava (SW1 e SW2) ---
        LDR R2, =OITAVA_ATUAL

        TST R1, #0x1000        ; Bit 12 (SW1)
        BNE check_sw2          ; Se não for 0 (não pressionado), vai pro próximo
        MOV R3, #0             ; Se pressionado (0), Oitava = 0
        STRB R3, [R2]
        B parte_timbre         ; Pula SW2 para evitar conflito

check_sw2
        TST R1, #0x2000        ; Bit 13 (SW2)
        BNE parte_timbre
        MOV R3, #1             ; Se pressionado, Oitava = 1
        STRB R3, [R2]

        ; --- Controle de Timbre (SW3 e SW4) ---
parte_timbre
        LDR R2, =TIMBRE_ATUAL
        LDRB R3, [R2]          ; Carrega valor atual

        ; SW3: Diminuir Timbre (Duty Cycle)
        TST R1, #0x4000        ; Bit 14 (SW3)
        BNE check_sw4          ; Se 1 (solto), vai verificar SW4
        
        ; Se chegou aqui, SW3 está pressionado
        SUB R3, R3, #5         ; Diminui 5%
        CMP R3, #5             ; Verifica limite mínimo (5%)
        BGE salva_timbre       ; Se R3 >= 5, salva
        MOV R3, #5             ; Se menor, trava em 5
        B salva_timbre

check_sw4
        TST R1, #0x8000        ; Bit 15 (SW4)
        BNE fim_atualiza       ; Se 1 (solto), termina
        
        ; Se chegou aqui, SW4 está pressionado
        ADD R3, R3, #5         ; Aumenta 5%
        CMP R3, #95            ; Verifica limite máximo (95%)
        BLE salva_timbre       ; Se R3 <= 95, salva
        MOV R3, #95            ; Se maior, trava em 95

salva_timbre
        STRB R3, [R2]          ; Salva na variável
        LDR R0, =TIM3_CCR3     ; Endereço do registro de Duty Cycle
        STR R3, [R0]           ; Atualiza o hardware do Timer

        BL delay_botao         

fim_atualiza
        POP {R0-R3, PC}

; ====================================================================
; DELAY PARA OS BOTÕES
; ====================================================================
delay_botao
        PUSH {R0, LR}
        LDR R0, =0x2FFFFF      ; Valor alto para delay
loop_db
        SUBS R0, R0, #1
        BNE loop_db
        POP {R0, PC}

toca_nota
        PUSH {R0-R3, R5, LR} 

        LDR R0, =PSC_TAB
        LSL R1, R4, #1
        LDRH R2, [R0, R1]   

        LDR R0, =OITAVA_ATUAL
        LDRB R3, [R0]
        CMP R3, #1
        BNE calcula_bending
        LSR R2, R2, #1

calcula_bending
        PUSH {R2}
        BL ler_potenciometro
        POP {R2}           

        MOV R5, R2              
        LSR R5, R5, #3        
        
        MUL R5, R5, R0        
        LSR R5, R5, #12       
        
        SUB R2, R2, R5      
        

envia_timer
        LDR R0, =TIM3_PSC
        STR R2, [R0]          

        LDR R0, =TIM3_CCER
        MOV R1, #0x0100
        STR R1, [R0]

        LDR R0, =TIM3_CR1
        MOV R1, #0x01
        STR R1, [R0]

        POP {R0-R3, R5, PC}

identifica_tecla
        PUSH {R0-R3, LR}

        MOV R4, #0xFF

        LDR R0, =GPIOB_IDR
        LDR R1, [R0]

        ; SW5 (PB5)
        TST R1, #0x0020        ; Bit 5
        BNE check_pb4
        MOV R4, #0
        B fim_identifica

check_pb4
        ; SW6 (PB4)
        TST R1, #0x0010        ; Bit 4
        BNE check_pb3
        MOV R4, #1
        B fim_identifica

check_pb3
        ; SW7 (PB3)
        TST R1, #0x0008        ; Bit 3
        BNE check_pa3
        MOV R4, #2
        B fim_identifica

check_pa3
        LDR R0, =GPIOA_IDR
        LDR R1, [R0]
        ; SW8 (PA3)
        TST R1, #0x0008        ; Bit 3
        BNE check_pa4
        MOV R4, #3
        B fim_identifica

check_pa4
        ; SW9 (PA4)
        TST R1, #0x0010        ; Bit 4
        BNE check_pb8
        MOV R4, #4
        B fim_identifica

check_pb8
        LDR R0, =GPIOB_IDR
        LDR R1, [R0]
        ; SW10 (PB8)
        TST R1, #0x0100        ; Bit 8
        BNE check_pb9
        MOV R4, #5
        B fim_identifica

check_pb9
        ; SW11 (PB9)
        TST R1, #0x0200        ; Bit 9
        BNE check_pb10
        MOV R4, #6
        B fim_identifica

check_pb10
        ; SW13 (PB10)
        TST R1, #0x0400        ; Bit 10
        BNE check_pa7
        MOV R4, #8
        B fim_identifica

check_pa7
        LDR R0, =GPIOA_IDR
        LDR R1, [R0]
        ; SW14 (PA7)
        TST R1, #0x0080        ; Bit 7
        BNE check_pc15
        MOV R4, #9
        B fim_identifica

check_pc15
        LDR R0, =GPIOC_IDR
        LDR R1, [R0]
        ; SW15 (PC15)
        TST R1, #0x8000        ; Bit 15
        BNE check_pc14
        MOV R4, #10
        B fim_identifica

check_pc14
        ; SW16 (PC14)
        TST R1, #0x4000        ; Bit 14
        BNE check_pc13
        MOV R4, #11
        B fim_identifica

check_pc13
        ; SW17 (PC13)
        TST R1, #0x2000        ; Bit 13
        BNE fim_identifica
        MOV R4, #12

fim_identifica
        POP {R0-R3, PC}
		
ler_potenciometro
        PUSH {R1, LR}

        ; Iniciar Conversão
        LDR R1, =ADC1_CR2
        LDR R0, [R1]
        ORR R0, R0, #1     
        STR R0, [R1]

wait_eoc
        LDR R1, =ADC1_SR
        LDR R0, [R1]
        TST R0, #2          
        BEQ wait_eoc        

        LDR R1, =ADC1_DR
        LDR R0, [R1]        
        
        POP {R1, PC}

        END