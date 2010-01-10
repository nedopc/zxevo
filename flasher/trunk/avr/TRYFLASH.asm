.NOLIST
.INCLUDE "M128DEF.INC"
.INCLUDE "_MACROS.ASM"
.LIST
.LISTMAC

.DEF    FF_FL   =R08
.DEF    FF      =R13    ;всегда = $FF
.DEF    ONE     =R14    ;всегда = $01
.DEF    NULL    =R15    ;всегда = $00
.DEF    DATA    =R16
.DEF    TEMP    =R17
.DEF    COUNT   =R18
.DEF    BITS    =R19
;локально используются: R0,R1,R20,R21,R24,R25

.EQU    DBSIZE_HI       =HIGH(4096)
.EQU    DBMASK_HI       =HIGH(4095)
.EQU    nCONFIG         =PORTF0
.EQU    nSTATUS         =PORTF1
.EQU    CONF_DONE       =PORTF2

.EQU    SD_DATA         =$57
.EQU    FLASH_LOADDR    =$F0
.EQU    FLASH_MIDADDR   =$F1
.EQU    FLASH_HIADDR    =$F2
.EQU    FLASH_DATA      =$F3
.EQU    FLASH_CTRL      =$F4
.EQU    SCR_LOADDR      =$40
.EQU    SCR_HIADDR      =$41
.EQU    SCR_CHAR        =$44

.MACRO  SS_SET
        SBI     PORTB,0
.ENDMACRO

.MACRO  SS_CLR
        CBI     PORTB,0
.ENDMACRO


.DSEG
        .ORG    $0100
BUFFER:                 ;главный буфер
;F_ADDR0:.BYTE   1
;F_ADDR1:.BYTE   1
;F_ADDR2:.BYTE   1

.CSEG
        .ORG    0
        JMP     START
        JMP     START   ;EXT_INT0 ; IRQ0 Handler
        JMP     START   ;EXT_INT1 ; IRQ1 Handler
        JMP     START   ;EXT_INT2 ; IRQ2 Handler
        JMP     START   ;EXT_INT3 ; IRQ3 Handler
        JMP     START   ;EXT_INT4 ; IRQ4 Handler
        JMP     START   ;EXT_INT5 ; IRQ5 Handler
        JMP     START   ;EXT_INT6 ; IRQ6 Handler
        JMP     START   ;EXT_INT7 ; IRQ7 Handler
        JMP     START   ;TIM2_COMP ; Timer2 Compare Handler
        JMP     START   ;TIM2_OVF ; Timer2 Overflow Handler
        JMP     START   ;TIM1_CAPT ; Timer1 Capture Handler
        JMP     START   ;TIM1_COMPA ; Timer1 CompareA Handler
        JMP     START   ;TIM1_COMPB ; Timer1 CompareB Handler
        JMP     START   ;TIM1_OVF ; Timer1 Overflow Handler
        JMP     START   ;TIM0_COMP ; Timer0 Compare Handler
        JMP     START   ;TIM0_OVF ; Timer0 Overflow Handler
        JMP     START   ;SPI_STC ; SPI Transfer Complete Handler
        JMP     START   ;USART0_RXC ; USART0 RX Complete Handler
        JMP     START   ;USART0_DRE ; USART0,UDR Empty Handler
        JMP     START   ;USART0_TXC ; USART0 TX Complete Handler
        JMP     START   ;ADC ; ADC Conversion Complete Handler
        JMP     START   ;EE_RDY ; EEPROM Ready Handler
        JMP     START   ;ANA_COMP ; Analog Comparator Handler
        JMP     START   ;TIM1_COMPC ; Timer1 CompareC Handler
        JMP     START   ;TIM3_CAPT ; Timer3 Capture Handler
        JMP     START   ;TIM3_COMPA ; Timer3 CompareA Handler
        JMP     START   ;TIM3_COMPB ; Timer3 CompareB Handler
        JMP     START   ;TIM3_COMPC ; Timer3 CompareC Handler
        JMP     START   ;TIM3_OVF ; Timer3 Overflow Handler
        JMP     START   ;USART1_RXC ; USART1 RX Complete Handler
        JMP     START   ;USART1_DRE; USART1,UDR Empty Handler
        JMP     START   ;USART1_TXC ; USART1 TX Complete Handler
        JMP     START   ;TWI_INT ; Two-wire Serial Interface Interrupt Handler
        JMP     START   ;SPM_RDY ; SPM Ready Handler

        .DW     0,0
;
START:  CLI
        CLR     NULL
        LDI     TEMP,$01
        MOV     ONE,TEMP
        LDI     TEMP,$FF
        MOV     FF,TEMP
;WatchDog OFF, если вдруг включен
        LDI     TEMP,0B00011111
        OUT     WDTCR,TEMP
        OUT     WDTCR,NULL
;будем юзать стек
        LDI     TEMP,LOW(RAMEND)
        OUT     SPL,TEMP
        LDI     TEMP,HIGH(RAMEND)
        OUT     SPH,TEMP


;юўш∙рхь эрїєщ тё■ ярь Є№ ш тёх ЁхушёЄЁ√

	ldi	r30,29
	ldi	r31,0
clr1:
	st	Z,r31
	dec	r30
	brpl	clr1

	ldi	r30,0
	ldi	r31,1 ; $0100
clr2:
	st	Z,r0
	adiw	r30,1
	cpi	r31,$11 ; <$1100
	brne	clr2



;
        LDI     TEMP,      0B11111111
        OUTPORT PORTG,TEMP
        LDI     TEMP,      0B00000000
        OUTPORT DDRG,TEMP

        LDI     TEMP,      0B00001000
        OUTPORT PORTF,TEMP
        OUTPORT DDRF,TEMP

        LDI     TEMP,      0B11111111
        OUTPORT PORTE,TEMP
        LDI     TEMP,      0B00000000
        OUTPORT DDRE,TEMP

        LDI     TEMP,      0B11111111
        OUTPORT PORTD,TEMP
        LDI     TEMP,      0B00000000
        OUTPORT DDRD,TEMP

        LDI     TEMP,      0B11011111
        OUTPORT PORTC,TEMP
        LDI     TEMP,      0B00000000
        OUTPORT DDRC,TEMP

        LDI     TEMP,      0B01111001
        OUTPORT PORTB,TEMP
        LDI     TEMP,      0B10000111
        OUTPORT DDRB,TEMP

        LDI     TEMP,      0B11111111
        OUTPORT PORTA,TEMP
        LDI     TEMP,      0B00000000
        OUTPORT DDRA,TEMP
;SPI init
        LDI     TEMP,(1<<SPI2X)
        OUT     SPSR,TEMP
        LDI     TEMP,(1<<SPE)|(1<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)
        OUT     SPCR,TEMP

;        SBIC    PINC,5
 ;       RJMP    UP12
  ;      SBI     PORTB,7
;UP11:   SBIS    PINC,5
 ;       RJMP    UP11
  ;      CBI     PORTB,7
;UP12:



	ldi DATA,10
	rcall DELAY






        INPORT  TEMP,DDRF
        SBR     TEMP,(1<<nCONFIG)
        OUTPORT DDRF,TEMP

        LDI     TEMP,147 ;40 us @ 11.0592 MHz
LDFPGA1:DEC     TEMP    ;1
        BRNE    LDFPGA1 ;2

        INPORT  TEMP,DDRF
        CBR     TEMP,(1<<nCONFIG)
        OUTPORT DDRF,TEMP

LDFPGA2:INPORT  DATA,PINF
        ANDI    DATA,(1<<nSTATUS)
        BREQ    LDFPGA2

        LDIZ    PACKED_FPGA*2
        LDIY    BUFFER
                                        ;A=DATA; A'=TEMP; B=R21; C=R20;
;deMLZ                                  ;DEC40
;(не трогаем стек! всё ОЗУ под буфер)
        LDI     TEMP,$80                ;        LD      A,#80
                                        ;        EX      AF,AF'--------
MS:     LPM     R0,Z+                   ;MS      LDI
        ST      Y+,R0
;-begin-PUT_BYTE_1---
        OUT     SPDR,R0
PUTB1:  IN      R1,SPSR
        SBRS    R1,SPIF
        RJMP    PUTB1
;-end---PUT_BYTE_1---
        SUBI    YH,HIGH(BUFFER) ;
        ANDI    YH,DBMASK_HI    ;Y warp
        ADDI    YH,HIGH(BUFFER) ;
M0:     LDI     R21,$02                 ;M0      LD      BC,#2FF
        LDI     R20,$FF
M1:                                     ;M1      EX      AF,AF'--------
M1X:    ADD     TEMP,TEMP               ;M1X     ADD     A,A
        BRNE    M2                      ;        JR      NZ,M2
        LPM     TEMP,Z+                 ;        LD      A,(HL)
                                        ;        INC     HL
        ROL     TEMP                    ;        RLA
M2:     ROL     R20                     ;M2      RL      C
        BRCC    M1X                     ;        JR      NC,M1X
                                        ;        EX      AF,AF'--------
        DEC     R21                     ;        DJNZ    X2
        BRNE    X2
        LDI     DATA,2                  ;        LD      A,2
        ASR     R20                     ;        SRA     C
        BRCS    N1                      ;        JR      C,N1
        INC     DATA                    ;        INC     A
        INC     R20                     ;        INC     C
        BREQ    N2                      ;        JR      Z,N2
        LDI     R21,$03                 ;        LD      BC,#33F
        LDI     R20,$3F
        RJMP    M1                      ;        JR      M1
                                        ;
X2:     DEC     R21                     ;X2      DJNZ    X3
        BRNE    X3
        LSR     R20                     ;        SRL     C
        BRCS    MS                      ;        JR      C,MS
        INC     R21                     ;        INC     B
        RJMP    M1                      ;        JR      M1
X6:                                     ;X6
        ADD     DATA,R20                ;        ADD     A,C
N2:     LDI     R21,$04                 ;N2
        LDI     R20,$FF                 ;        LD      BC,#4FF
        RJMP    M1                      ;        JR      M1
N1:                                     ;N1
        INC     R20                     ;        INC     C
        BRNE    M4                      ;        JR      NZ,M4
                                        ;        EX      AF,AF'--------
        INC     R21                     ;        INC     B
N5:     ROR     R20                     ;N5      RR      C
        BRCS    DEMLZEND                ;        RET     C
        ROL     R21                     ;        RL      B
        ADD     TEMP,TEMP               ;        ADD     A,A
        BRNE    N6                      ;        JR      NZ,N6
        LPM     TEMP,Z+                 ;        LD      A,(HL)
                                        ;        INC     HL
        ROL     TEMP                    ;        RLA
N6:     BRCC    N5                      ;N6      JR      NC,N5
                                        ;        EX      AF,AF'--------
        ADD     DATA,R21                ;        ADD     A,B
        LDI     R21,6                   ;        LD      B,6
        RJMP    M1                      ;        JR      M1
X3:     DEC     R21                     ;X3
        BRNE    X4                      ;        DJNZ    X4
        LDI     DATA,1                  ;        LD      A,1
        RJMP    M3                      ;        JR      M3
X4:     DEC     R21                     ;X4      DJNZ    X5
        BRNE    X5
        INC     R20                     ;        INC     C
        BRNE    M4                      ;        JR      NZ,M4
        LDI     R21,$05                 ;        LD      BC,#51F
        LDI     R20,$1F
        RJMP    M1                      ;        JR      M1
X5:     DEC     R21                     ;X5
        BRNE    X6                      ;        DJNZ    X6
        MOV     R21,R20                 ;        LD      B,C
M4:     LPM     R20,Z+                  ;M4      LD      C,(HL)
                                        ;        INC     HL
M3:     DEC     R21                     ;M3      DEC     B
                                        ;        PUSH    HL
        MOV     XL,R20                  ;        LD      L,C
        MOV     XH,R21                  ;        LD      H,B
        ADD     XL,YL                   ;        ADD     HL,DE
        ADC     XH,YH
                                        ;        LD      C,A
                                        ;        LD      B,0
LDIRLOOP:
        SUBI    XH,HIGH(BUFFER) ;
        ANDI    XH,DBMASK_HI    ;X warp
        ADDI    XH,HIGH(BUFFER) ;
        LD      R0,X+                   ;        LDIR
        ST      Y+,R0
;-begin-PUT_BYTE_2---
        OUT     SPDR,R0
PUTB2:  IN      R1,SPSR
        SBRS    R1,SPIF
        RJMP    PUTB2
;-end---PUT_BYTE_2---
        SUBI    YH,HIGH(BUFFER) ;
        ANDI    YH,DBMASK_HI    ;Y warp
        ADDI    YH,HIGH(BUFFER) ;
        DEC     DATA
        BRNE    LDIRLOOP
                                        ;        POP     HL
        RJMP    M0                      ;        JR      M0
                                        ;END_DEC40
DEMLZEND:;теперь можно юзать стек
;SPI reinit

;цф╕ь, яюър яюфэшьхЄё  CONF_DONE - чэрўшЄ, ўЄю яЁю°штър тёюёрырё№ ш чрЁрсюЄрыр, тё╕ чрхсшё№
qwertyu:inport  DATA,PINF
        andi    DATA,(1<<CONF_DONE)
        breq    qwertyu




        LDI     TEMP,(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)
        OUT     SPCR,TEMP
;для beeper-а
        SBI     DDRE,6
;св.диод погасить
        SBI     PORTB,7
; - - - - - - - - - - - - - - - - - - -
        LDI     XL,0
        LDI     XH,0
        RCALL   SET_SCR_CURSOR
        LDIZ    MSG_ID_FLASH*2
        RCALL   SCR_PRINTSTRZ

        RCALL   F_ID
        MOV     DATA,XL
        RCALL   HEXBYTE
        LDI     DATA,$20
        RCALL   PUTCHAR
        MOV     DATA,XH
        RCALL   HEXBYTE
; - - - - - - - - - - - - - - - - - - -
        LDIZ    MSG_F_ERASE*2
        RCALL   SCR_PRINTSTRZ
        RCALL   F_ERASE
; - - - - - - - - - - - - - - - - - - -
        LDIZ    MSG_F_WRITE*2
        RCALL   SCR_PRINTSTRZ

        LDIZ    ROM*2
        OUT     RAMPZ,NULL
; - - - - - - - - - - - - - - - - - - -
        LDI     XL,0
        LDI     XH,1
        RCALL   SET_SCR_CURSOR
        LDIY    $0000
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,2
        RCALL   SET_SCR_CURSOR
        LDIY    $0001
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,3
        RCALL   SET_SCR_CURSOR
        LDIY    $0002
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,4
        RCALL   SET_SCR_CURSOR
        LDIY    $0003
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,5
        RCALL   SET_SCR_CURSOR
        LDIY    $0004
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,6
        RCALL   SET_SCR_CURSOR
        LDIY    $0005
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,7
        RCALL   SET_SCR_CURSOR
        LDIY    $0006
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,8
        RCALL   SET_SCR_CURSOR
        LDIY    $0007
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,9
        RCALL   SET_SCR_CURSOR
        LDIY    $0008
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,10
        RCALL   SET_SCR_CURSOR
        LDIY    $0009
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,11
        RCALL   SET_SCR_CURSOR
        LDIY    $000A
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,12
        RCALL   SET_SCR_CURSOR
        LDIY    $000B
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,13
        RCALL   SET_SCR_CURSOR
        LDIY    $000C
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,14
        RCALL   SET_SCR_CURSOR
        LDIY    $000D
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,15
        RCALL   SET_SCR_CURSOR
        LDIY    $000E
        RCALL   F_WRITE

        LDI     XL,0
        LDI     XH,16
        RCALL   SET_SCR_CURSOR
        LDIY    $000F
        RCALL   F_WRITE
; - - - - - - - - - - - - - - - - - - -
        RCALL   F_RST
        LDI     XL,0
        LDI     XH,23
        RCALL   SET_SCR_CURSOR
        LDIZ    MSG_F_COMPLETE*2
        RCALL   SCR_PRINTSTRZ
STOP1:  RJMP    STOP1
;
;--------------------------------------
;--------------------------------------
;
F_ID:   RCALL   F_RST
        LDI     DATA,$90
        RCALL   F_CMD
        LDI     TEMP,FLASH_CTRL
        LDI     DATA,0B00000011
        RCALL   FPGA_REG
        LDI     YL,$00
        LDI     YH,$00
        RCALL   F_IN
        MOV     XL,DATA
        LDI     YL,$01
        RCALL   F_IN
        MOV     XH,DATA
        RJMP    F_RST
;
;--------------------------------------
;in:    FLASH[Z] - data
;       YL,YH - address
F_WRITE:
        MOV     DATA,YH
        RCALL   HEXBYTE
        MOV     DATA,YL
        RCALL   HEXBYTE
        LDI     DATA,$20
        RCALL   PUTCHAR

        LDI     DATA,$A0
        RCALL   F_CMD
        ELPM    DATA,Z
        RCALL   F_OUT
        LDI     TEMP,FLASH_CTRL
        LDI     DATA,0B00000011
        RCALL   FPGA_REG
;1
        LDI     TEMP,FLASH_DATA
        RCALL   FPGA_REG
        PUSH    DATA
        RCALL   HEXBYTE
        LDI     DATA,$20
        RCALL   PUTCHAR
        POP     DATA
        ELPM    TEMP,Z
        EOR     DATA,TEMP
        SBRS    DATA,7
        RJMP    F_WRIT9
;2
        LDI     TEMP,FLASH_DATA
        RCALL   FPGA_REG
        PUSH    DATA
        RCALL   HEXBYTE
        LDI     DATA,$20
        RCALL   PUTCHAR
        POP     DATA
        ELPM    TEMP,Z
        EOR     DATA,TEMP
        SBRS    DATA,7
        RJMP    F_WRIT9
;3
        LDI     TEMP,FLASH_DATA
        RCALL   FPGA_REG
        PUSH    DATA
        RCALL   HEXBYTE
        LDI     DATA,$20
        RCALL   PUTCHAR
        POP     DATA
        ELPM    TEMP,Z
        EOR     DATA,TEMP
        SBRS    DATA,7
        RJMP    F_WRIT9
;4
        LDI     TEMP,FLASH_DATA
        RCALL   FPGA_REG
        PUSH    DATA
        RCALL   HEXBYTE
        LDI     DATA,$20
        RCALL   PUTCHAR
        POP     DATA
        ELPM    TEMP,Z
        EOR     DATA,TEMP
        SBRS    DATA,7
        RJMP    F_WRIT9
;5
        LDI     TEMP,FLASH_DATA
        RCALL   FPGA_REG
        PUSH    DATA
        RCALL   HEXBYTE
        LDI     DATA,$20
        RCALL   PUTCHAR
        POP     DATA
        ELPM    TEMP,Z
        EOR     DATA,TEMP
        SBRS    DATA,7
        RJMP    F_WRIT9
;6
        LDI     TEMP,FLASH_DATA
        RCALL   FPGA_REG
        PUSH    DATA
        RCALL   HEXBYTE
        LDI     DATA,$20
        RCALL   PUTCHAR
        POP     DATA
        ELPM    TEMP,Z
        EOR     DATA,TEMP
        SBRS    DATA,7
        RJMP    F_WRIT9
;7
        LDI     TEMP,FLASH_DATA
        RCALL   FPGA_REG
        PUSH    DATA
        RCALL   HEXBYTE
        LDI     DATA,$20
        RCALL   PUTCHAR
        POP     DATA
        ELPM    TEMP,Z
        EOR     DATA,TEMP
        SBRS    DATA,7
        RJMP    F_WRIT9
;8
        LDI     TEMP,FLASH_DATA
        RCALL   FPGA_REG
        PUSH    DATA
        RCALL   HEXBYTE
        LDI     DATA,$20
        RCALL   PUTCHAR
        POP     DATA
        ELPM    TEMP,Z
        EOR     DATA,TEMP
        SBRS    DATA,7
        RJMP    F_WRIT9
;9
        LDI     TEMP,FLASH_DATA
        RCALL   FPGA_REG
        PUSH    DATA
        RCALL   HEXBYTE
        LDI     DATA,$20
        RCALL   PUTCHAR
        POP     DATA
        ELPM    TEMP,Z
        EOR     DATA,TEMP
        SBRS    DATA,7
        RJMP    F_WRIT9
F_WRIT1:
        LDI     TEMP,SCR_LOADDR
        LDI     DATA,29
        RCALL   FPGA_REG
        LDI     TEMP,SCR_HIADDR
        LDI     DATA,0
        RCALL   FPGA_REG

        LDI     TEMP,FLASH_DATA
        RCALL   FPGA_REG

        PUSH    DATA
        RCALL   HEXBYTE
        POP     DATA

        ELPM    TEMP,Z
        EOR     DATA,TEMP
        SBRC    DATA,7
        RJMP    F_WRIT1

F_WRIT9:ELPM    TEMP,Z+
        RET
;
;--------------------------------------
;
F_ERASE:LDI     DATA,$80
        RCALL   F_CMD
        LDI     DATA,$10
        RCALL   F_CMD
        LDI     TEMP,FLASH_CTRL
        LDI     DATA,0B00000011
        RCALL   FPGA_REG

F_ERAS1:SBI     PORTB,7 ;св.диод погасить

        LDI     TEMP,SCR_LOADDR
        LDI     DATA,17
        RCALL   FPGA_REG
        LDI     TEMP,SCR_HIADDR
        LDI     DATA,0
        RCALL   FPGA_REG

        LDI     TEMP,FLASH_DATA
        RCALL   FPGA_REG

        PUSH    DATA
        RCALL   HEXBYTE
        POP     DATA

        CBI     PORTB,7 ;св.диод зажечь
        SBRS    DATA,7
        RJMP    F_ERAS1
;
; - - - - - - - - - - - - - - - - - - -
;
F_RST:  LDI     DATA,$F0
        RCALL   F_CMD
        LDI     TEMP,19 ;~5 us @ 11.0592 MHz
F_RST1: DEC     TEMP    ;1
        BRNE    F_RST1  ;2
        RET
;
;--------------------------------------
;in:    DATA - instructions
F_CMD:  PUSH    DATA
        LDI     TEMP,FLASH_CTRL
        LDI     DATA,0B00000001
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_LOADDR
        LDI     DATA,$55
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_MIDADDR
        LDI     DATA,$55
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_DATA
        LDI     DATA,$AA
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_CTRL
        LDI     DATA,0B00000101
        RCALL   FPGA_REG
        LDI     DATA,0B00000001
        RCALL   FPGA_SAME_REG
        LDI     TEMP,FLASH_LOADDR
        LDI     DATA,$AA
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_MIDADDR
        LDI     DATA,$2A
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_DATA
        LDI     DATA,$55
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_CTRL
        LDI     DATA,0B00000101
        RCALL   FPGA_REG
        LDI     DATA,0B00000001
        RCALL   FPGA_SAME_REG
        LDI     TEMP,FLASH_LOADDR
        LDI     DATA,$55
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_MIDADDR
        LDI     DATA,$55
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_DATA
        POP     DATA
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_CTRL
        LDI     DATA,0B00000101
        RCALL   FPGA_REG
        LDI     DATA,0B00000001
        RJMP    FPGA_SAME_REG
;
;--------------------------------------
;in:    YL,YH - address
;out:   DATA - data
F_IN:
        LDI     TEMP,FLASH_LOADDR
        MOV     DATA,YL
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_MIDADDR
        MOV     DATA,YH
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_HIADDR
        LDI     DATA,$00
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_DATA
        LDI     DATA,$FF
        RJMP    FPGA_REG
;
;--------------------------------------
;in:    YL,YH - address
;       DATA - data
F_OUT:  PUSH    DATA
        LDI     TEMP,FLASH_CTRL
        LDI     DATA,0B00000001
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_LOADDR
        MOV     DATA,YL
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_MIDADDR
        MOV     DATA,YH
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_HIADDR
        LDI     DATA,$00
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_DATA
        POP     DATA
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_CTRL
        LDI     DATA,0B00000101
        RCALL   FPGA_REG
        LDI     DATA,0B00000001
        RJMP    FPGA_SAME_REG
;
;--------------------------------------
;
FPGA_REG:
        PUSH    DATA
        SS_SET
        OUT     SPDR,TEMP
        RCALL   RD_WHEN_RDY
        POP     DATA
FPGA_SAME_REG:
        SS_CLR
        OUT     SPDR,DATA
;
RD_WHEN_RDY:
        IN      R0,SPSR
        SBRS    R0,SPIF
        RJMP    RD_WHEN_RDY
        IN      DATA,SPDR
        SS_SET
        RET
;--------------------------------------
;in:    XL - x (0..31)
;       XH - y (0..23)
SET_SCR_CURSOR:
        LDI     TEMP,32
        MUL     XH,TEMP
        CLR     XH
        ADD     XL,R0
        ADC     XH,R1
        SBIW    XL,1
        LDI     TEMP,SCR_LOADDR
        MOV     DATA,XL
        RCALL   FPGA_REG
        LDI     TEMP,SCR_HIADDR
        MOV     DATA,XH
        RJMP    FPGA_REG
;
;--------------------------------------
;in:    Z == указательна строку (в младших 64K)
SCR_PRINTSTRZ:
        SS_SET
        LDI     TEMP,SCR_CHAR
        OUT     SPDR,TEMP
        RCALL   RD_WHEN_RDY
SCR_PRSTRZ1:
        LPM     DATA,Z+
        TST     DATA
        BREQ    SCR_PRSTRZ2
        RCALL   FPGA_SAME_REG
        RJMP    SCR_PRSTRZ1
SCR_PRSTRZ2:
        RET
;
;--------------------------------------
;in:    DATA == byte
HEXBYTE:PUSH    DATA
        SWAP    DATA
        RCALL   HEXHALF
        POP     DATA
HEXHALF:ANDI    DATA,$0F
        CPI     DATA,$0A
        BRCS    HEXBYT1
        ADDI    DATA,$07
HEXBYT1:ADDI    DATA,$30
;
; - - - - - - - - - - - - - - - - - - -
;in:    DATA
PUTCHAR:PUSH    TEMP
        SS_SET
        LDI     TEMP,SCR_CHAR
        RCALL   FPGA_REG
        POP     TEMP
        RET
;





;DELAY
;in:    DATA/10 == количество секунд
DELAY:
        LDI     R20,$1E ;\
        LDI     R21,$FE ;/ 0,1 сек @ 11.0592MHz
DELAY1: LPM             ;3
        LPM             ;3
        LPM             ;3
        LPM             ;3
        SUBI    R20,1   ;1
        SBCI    R21,0   ;1
        SBCI    DATA,0  ;1
        BRNE    DELAY1  ;2(1)
        RET
;



;--------------------------------------
;
;01234567890123456789012345678901
;ID: xx xx   Erase xx   Write
;0000 11 22 33 44 55 66 77 88 99
;
MSG_ID_FLASH:
        .DB     "ID: ",0,0
MSG_F_ERASE:
        .DB     "   Erase ",0
MSG_F_WRITE:    ;12345678901234567890123456789012
        .DB     "   Write ",0
MSG_F_COMPLETE:
        .DB     "=========== Complete ===========",0,0
;
PACKED_FPGA:
.NOLIST
.INCLUDE "FPGA1.INC"
;
ROM:    .DB     $00,$55,$AA,$33,$CC,$99,$66,$F0,$0F,$5A,$A5,$3C,$C3,$96,$69,$FF
