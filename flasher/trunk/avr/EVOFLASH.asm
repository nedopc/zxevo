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

.EQU    CMD_17          =$51    ;read_single_block
.EQU    ACMD_41         =$69    ;sd_send_op_cond

.EQU    SD_DATA         =$57
.EQU    FLASH_LOADDR    =$F0
.EQU    FLASH_MIDADDR   =$F1
.EQU    FLASH_HIADDR    =$F2
.EQU    FLASH_DATA      =$F3
.EQU    FLASH_CTRL      =$F4

.MACRO  SS_SET
        SBI     PORTB,0
.ENDMACRO

.MACRO  SS_CLR
        CBI     PORTB,0
.ENDMACRO


.DSEG
        .ORG    $0100
BUFFER:                 ;главный буфер
        .ORG    $0200
BUFSECT:                ;буфер сектора
        .ORG    $0400
BUF4FAT:                ;временный буфер (FAT и т.п.)
        .ORG    $0600
HEADER:                 ;заголовок файла
        .ORG    $0680
CAL_FAT:.BYTE   1       ;тип обнаруженной FAT
MANYFAT:.BYTE   1       ;количество FAT-таблиц
BYTSSEC:.BYTE   1       ;количество секторов в кластере
ROOTCLS:.BYTE   4       ;сектор начала root директории
SEC_FAT:.BYTE   4       ;количество секторов одной FAT
RSVDSEC:.BYTE   2       ;размер резервной области
STARTRZ:.BYTE   4       ;начало диска/раздела
FRSTDAT:.BYTE   4       ;адрес первого сектора данных от BPB
SEC_DSC:.BYTE   4       ;количество секторов на диске/разделе
CLS_DSC:.BYTE   4       ;количество кластеров на диске/разделе
FATSTR0:.BYTE   4       ;начало первой FAT таблицы
FATSTR1:.BYTE   4       ;начало второй FAT таблицы
TEK_DIR:.BYTE   4       ;кластер текущей директории
KCLSDIR:.BYTE   1       ;кол-во кластеров директории
NUMSECK:.BYTE   1       ;счетчик секторов в кластере
TFILCLS:.BYTE   4       ;текущий кластер
MPHWOST:.BYTE   1       ;кол-во секторов в последнем кластере
KOL_CLS:.BYTE   4       ;кол-во кластеров файла минус 1
;STEP:
SDERROR:.BYTE   1
LASTSECFLAG:
        .BYTE   1
F_ADDR0:.BYTE   1
F_ADDR1:.BYTE   1
F_ADDR2:.BYTE   1

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
        .DB     "================"
        .DB     " ZX Evo Flasher "
        .DB     "================"
;
        .ORG    $DF00
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
;будем юзать ELPM
        OUT     RAMPZ,ONE
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
;UART1 Set baud rate
        OUTPORT UBRR1H,NULL
        LDI     TEMP,5     ;115200 baud, 11059.2 kHz, Normal speed
        OUTPORT UBRR1L,TEMP
;UART1 Normal Speed
        OUTPORT UCSR1A,NULL
;UART1 data8bit, 2stopbits
        LDI     TEMP,(1<<UCSZ1)|(1<<UCSZ0)|(1<<USBS)
        OUTPORT UCSR1C,TEMP
;UART1 Разрешаем передачу
        LDI     TEMP,(1<<TXEN)
        OUTPORT UCSR1B,TEMP

        LDIZ    MSG_TITLE*2
        RCALL   PRINTSTRZ

        SBIC    PINC,5
        RJMP    UP12
        LDIZ    MSG_POWERON*2
        RCALL   PRINTSTRZ
        SBI     PORTB,7
UP11:   SBIS    PINC,5
        RJMP    UP11
        CBI     PORTB,7

UP12:   LDIZ    MSG_CFGFPGA*2
        RCALL   PRINTSTRZ

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
MS:     ELPM    R0,Z+                   ;MS      LDI
        ST      Y+,R0
;-begin-PUT_BYTE_1---
;UART тут для отладки ;)
;WRUX1:  INPORT  R1,UCSR1A
;        SBRS    R1,UDRE
;        RJMP    WRUX1
;        OUTPORT UDR1,R0
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
        ELPM    TEMP,Z+                 ;        LD      A,(HL)
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
        ELPM    TEMP,Z+                 ;        LD      A,(HL)
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
M4:     ELPM    R20,Z+                  ;M4      LD      C,(HL)
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
;UART тут для отладки ;)
;WRUX2:  INPORT  R1,UCSR1A
;        SBRS    R1,UDRE
;        RJMP    WRUX2
;        OUTPORT UDR1,R0
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
        LDI     TEMP,(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)
        OUT     SPCR,TEMP
;для beeper-а
        SBI     DDRE,6
;св.диод погасить
        SBI     PORTB,7
;
; - - - - - - - - - - - - - - - - - - -
;
        LDIZ    MSG_ID_FLASH*2
        RCALL   PRINTSTRZ

        RCALL   F_ID
        MOV     DATA,XL
        RCALL   HEXBYTE
        LDI     DATA,$20
        RCALL   WRUART
        MOV     DATA,XH
        RCALL   HEXBYTE

        LDIZ    MSG_OPENFILE*2
        RCALL   PRINTSTRZ
;
; - - - - - - - - - - - - - - - - - - -
;инициализация SD карточки
        SS_SET
        LDI     DATA,SD_DATA
        OUT     SPDR,DATA
SDINIT0:IN      R0,SPSR
        SBRS    R0,SPIF
        RJMP    SDINIT0
        IN      R0,SPDR
        SS_CLR

        LDI     TEMP,32
        RCALL   SD_RD_DUMMY
        SER     R24
SDINIT1:LDIZ    CMD00*2
        RCALL   SD_WR_PGM_6
        DEC     R24
        BRNE    SDINIT2
       LDI     DATA,1  ;нет SD
        RJMP    SD_ERROR
SDINIT2:CPI     DATA,$01
        BRNE    SDINIT1

        LDIZ    CMD08*2
        RCALL   SD_WR_PGM_6
        LDI     R24,$00
        SBRS    DATA,2
        LDI     R24,$40
        LDI     TEMP,4
        RCALL   SD_RD_DUMMY

SDINIT3:LDIZ    CMD55*2
        RCALL   SD_WR_PGM_6
        LDI     DATA,ACMD_41
        RCALL   SD_EXCHANGE
        MOV     DATA,R24
        RCALL   SD_EXCHANGE

        LDIZ    CMD55*2+2
        LDI     TEMP,4
        RCALL   SD_WR_PGX
        TST     DATA
        BRNE    SDINIT3

SDINIT4:LDIZ    CMD59*2
        RCALL   SD_WR_PGM_6
        TST     DATA
        BRNE    SDINIT4

SDINIT5:LDIZ    CMD16*2
        RCALL   SD_WR_PGM_6
        TST     DATA
        BRNE    SDINIT5
;
; - - - - - - - - - - - - - - - - - - -
;поиск FAT, инициализация переменных
WC_FAT: LDIX    0
        LDIY    0
        RCALL   LOADLST
        LDIZ    BUF4FAT+$01BE
        LD      DATA,Z
        TST     DATA
        BRNE    RDFAT05
        LDI     ZL,$C2
        LD      DATA,Z
        LDI     TEMP,0
        CPI     DATA,$01
        BREQ    RDFAT06
        LDI     TEMP,2
        CPI     DATA,$0B
        BREQ    RDFAT06
        CPI     DATA,$0C
        BREQ    RDFAT06
        LDI     TEMP,1
        CPI     DATA,$06
        BREQ    RDFAT06
        CPI     DATA,$0E
        BRNE    RDFAT05
RDFAT06:STS     CAL_FAT,TEMP
        LDI     ZL,$C6
        LD      XL,Z+
        LD      XH,Z+
        LD      YL,Z+
        LD      YH,Z
        RJMP    RDFAT00
RDFAT05:LDIZ    BUF4FAT
        LDD     BITS,Z+$0D
        LDI     DATA,0
        LDI     TEMP,0
        LDI     COUNT,8
RDF051: ROR     BITS
        ADC     DATA,NULL
        DEC     COUNT
        BRNE    RDF051
        DEC     DATA
        BRNE    RDF052
        INC     TEMP
RDF052: LDD     DATA,Z+$0E
        LDD     R0,Z+$0F
        OR      DATA,R0
        BREQ    RDF053
        INC     TEMP
RDF053: LDD     DATA,Z+$13
        LDD     R0,Z+$14
        OR      DATA,R0
        BRNE    RDF054
        INC     TEMP
RDF054: LDD     DATA,Z+$20
        LDD     R0,Z+$21
        OR      DATA,R0
        LDD     R0,Z+$22
        OR      DATA,R0
        LDD     R0,Z+$23
        OR      DATA,R0
        BRNE    RDF055
        INC     TEMP
RDF055: LDD     DATA,Z+$15
        ANDI    DATA,$F0
        CPI     DATA,$F0
        BRNE    RDF056
        INC     TEMP
RDF056: CPI     TEMP,4
        BREQ    RDF057
       LDI     DATA,3  ;не найдена FAT
        RJMP    SD_ERROR
RDF057: STS     CAL_FAT,FF
        LDIY    0
        LDIX    0
RDFAT00:STSX    STARTRZ+0
        STSY    STARTRZ+2
        RCALL   LOADLST
        LDIY    0
        LDD     XL,Z+22
        LDD     XH,Z+23         ;bpb_fatsz16
        MOV     DATA,XH
        OR      DATA,XL
        BRNE    RDFAT01         ;если не fat12/16 (bpb_fatsz16=0)
        LDD     XL,Z+36         ;то берем bpb_fatsz32 из смещения +36
        LDD     XH,Z+37
        LDD     YL,Z+38
        LDD     YH,Z+39
RDFAT01:STSX    SEC_FAT+0
        STSY    SEC_FAT+2       ;число секторов на fat-таблицу
        LDIY    0
        LDD     XL,Z+19
        LDD     XH,Z+20         ;bpb_totsec16
        MOV     DATA,XH
        OR      DATA,XL
        BRNE    RDFAT02         ;если не fat12/16 (bpb_totsec16=0)
        LDD     XL,Z+32         ;то берем из bpb_totsec32 смещения +32
        LDD     XH,Z+33
        LDD     YL,Z+34
        LDD     YH,Z+35
RDFAT02:STSX    SEC_DSC+0
        STSY    SEC_DSC+2       ;к-во секторов на диске/разделе
;вычисляем rootdirsectors
        LDD     XL,Z+17
        LDD     XH,Z+18         ;bpb_rootentcnt
        LDIY    0
        MOV     DATA,XH
        OR      DATA,XL
        BREQ    RDFAT03
        LDI     DATA,$10
        RCALL   BCDE_A
        MOVW    YL,XL           ;это реализована формула
                                ;rootdirsectors = ( (bpb_rootentcnt*32)+(bpb_bytspersec-1) )/bpb_bytspersec
                                ;в Y rootdirsectors
                                ;если fat32, то Y=0 всегда
RDFAT03:PUSH    YH
        PUSH    YL
        LDD     DATA,Z+16       ;bpb_numfats
        STS     MANYFAT,DATA
        LDSX    SEC_FAT+0
        LDSY    SEC_FAT+2
        DEC     DATA
RDF031: LSL     XL
        ROL     XH
        ROL     YL
        ROL     YH
        DEC     DATA
        BRNE    RDF031
        POP     R24
        POP     R25
                                ;полный размер fat-области в секторах
        RCALL   HLDEPBC         ;прибавили rootdirsectors
        LDD     R24,Z+14
        LDD     R25,Z+15        ;bpb_rsvdseccnt
        STS     RSVDSEC+0,R24
        STS     RSVDSEC+1,R25
        RCALL   HLDEPBC         ;прибавили bpb_resvdseccnt
        STSX    FRSTDAT+0
        STSY    FRSTDAT+2       ;положили номер первого сектора данных
        LDIZ    SEC_DSC
        RCALL   BCDEHLM         ;вычли из полного к-ва секторов раздела
        LDIZ    BUF4FAT
        LDD     DATA,Z+13
        STS     BYTSSEC,DATA
        RCALL   BCDE_A          ;разделили на к-во секторов в кластере
        STSX    CLS_DSC+0
        STSY    CLS_DSC+2       ;положили кол-во кластеров на разделе

        LDS     DATA,CAL_FAT
        CPI     DATA,$FF
        BRNE    RDFAT04
        LDSX    CLS_DSC+0
        LDSY    CLS_DSC+2
        PUSHY
        PUSHX
        LSL     XL
        ROL     XH
        ROL     YL
        ROL     YH
        RCALL   RASCHET
        LDI     DATA,1
        POPX
        POPY
        BREQ    RDFAT04
        LSL     XL
        ROL     XH
        ROL     YL
        ROL     YH
        LSL     XL
        ROL     XH
        ROL     YL
        ROL     YH
        RCALL   RASCHET
        LDI     DATA,2
        BREQ    RDFAT04
        CLR     DATA
RDFAT04:STS     CAL_FAT,DATA
;для fat12/16 вычисляем адрес первого сектора директории
;для fat32 берем по смещемию +44
;на выходе YX == сектор rootdir
        LDIX    0
        LDIY    0
        TST     DATA
        BREQ    FSRROO2
        DEC     DATA
        BREQ    FSRROO2
        LDD     XL,Z+44
        LDD     XH,Z+45
        LDD     YL,Z+46
        LDD     YH,Z+47
FSRROO2:STSX    ROOTCLS+0
        STSY    ROOTCLS+2       ;сектор root директории
        STSX    TEK_DIR+0
        STSY    TEK_DIR+2

FSRR121:PUSHX
        PUSHY
        LDSX    RSVDSEC
        LDIY    0
        LDIZ    STARTRZ
        RCALL   BCDEHLP
        STSX    FATSTR0+0
        STSY    FATSTR0+2
        LDIZ    SEC_FAT
        RCALL   BCDEHLP
        STSX    FATSTR1+0
        STSY    FATSTR1+2
        POPY
        POPX

        LDI     TEMP,1
        MOV     R0,XL
        OR      R0,XH
        OR      R0,YL
        OR      R0,YH
        BREQ    LASTCLS
NEXTCLS:PUSH    TEMP
        RCALL   RDFATZP
        RCALL   LST_CLS
        POP     TEMP
        BREQ    LASTCLS
        INC     TEMP
        RJMP    NEXTCLS
LASTCLS:STS     KCLSDIR,TEMP
        LDIY    0
        RCALL   RDDIRSC
;
; - - - - - - - - - - - - - - - - - - -
;поиск файла в директории
        LDIY    0               ;номер описателя файла
        RJMP    FNDMP32

FNDMP31:ADIW    YL,1            ;номер++               ─────────┐
        ADIW    ZL,$20          ;следующий описатель             │
        CPI     ZH,HIGH(BUF4FAT+512);                            │
                                ;вылезли за сектор?              │
        BRNE    FNDMP32         ;нет ещё                         │
        RCALL   RDDIRSC         ;считываем следующий             │
        BRNE    FNDMP37         ;кончились сектора в директории ═│═╗
FNDMP32:LDD     DATA,Z+$0B      ;атрибуты                        │ ║
        SBRC    DATA,3          ;длиное имя/имя диска?           │ ║
        RJMP    FNDMP31         ;да ────────────────────────────┤ ║
        SBRC    DATA,4          ;директория?                     │ ║
        RJMP    FNDMP31         ;да ────────────────────────────┤ ║
        LD      DATA,Z          ;первый символ                   │ ║
        CPI     DATA,$E5        ;удалённый файл?                 │ ║
        BREQ    FNDMP31         ;да ────────────────────────────┘ ║
        TST     DATA            ;пустой описатель? (конец списка)  ╚═ в этой директории
        BREQ    FNDMP37         ;да ═════════════════════════════════ нет нашёго файла
        PUSH    ZL
        MOVW    XL,ZL
        LDIZ    FILENAME*2
DALSHE: ELPM    DATA,Z+
        TST     DATA
        BREQ    NASHEL
        LD      TEMP,X+
        CP      DATA,TEMP
        BREQ    DALSHE
;не совпало
        MOV     ZH,XH
        POP     ZL
        RJMP    FNDMP31
;нет такого файла
FNDMP37:
       LDI     DATA,4  ;нет файла
        RJMP    SD_ERROR
;найден описатель
NASHEL: MOV     ZH,XH
        POP     ZL
;
; - - - - - - - - - - - - - - - - - - -
;инициализация переменных
;для последующего чтения файла
;Z указывает на описатель файла
        LDD     XL,Z+$1A
        LDD     XH,Z+$1B
        LDD     YL,Z+$14
        LDD     YH,Z+$15        ;считали номер первого кластера файла
        STSX    TFILCLS+0
        STSY    TFILCLS+2
        LDD     XL,Z+$1C
        LDD     XH,Z+$1D
        LDD     YL,Z+$1E
        LDD     YH,Z+$1F        ;считали длину файла

        MOV     DATA,XL
        OR      DATA,XH
        OR      DATA,YL
        OR      DATA,YH
        BRNE    F01
       LDI     DATA,5  ;пустой файл
        RJMP    SD_ERROR
F01:
        TST     YH
        BRNE    FILE_BIG        ;большой файл
        MOV     DATA,YL
        ANDI    DATA,$F8
        BREQ    F02
FILE_BIG:
       LDI     DATA,6  ;большой файл
        RJMP    SD_ERROR
F02:
        LDI     R24,LOW(511)
        LDI     R25,HIGH(511)
        RCALL   HLDEPBC
        RCALL   BCDE200         ;получили кол-во секторов
        SBIW    XL,1
        SBC     YL,NULL
        SBC     YH,NULL
        LDS     DATA,BYTSSEC
        DEC     DATA
        AND     DATA,XL
        INC     DATA
        STS     MPHWOST,DATA    ;кол-во секторов в последнем кластере
        LDS     DATA,BYTSSEC
        RCALL   BCDE_A
        STSX    KOL_CLS+0
        STSY    KOL_CLS+2
        STS     NUMSECK,NULL
; - - - - - - - - - - - - - - - - - - -
        LDIZ    MSG_F_CONFIRM*2
        RCALL   PRINTSTRZ
;св.диод зажечь
        CBI     PORTB,7
        RCALL   SOFTBUTTON

        LDIZ    MSG_F_ERASE*2
        RCALL   PRINTSTRZ
        RCALL   F_ERASE
;
        LDIZ    MSG_F_WRITE*2
        RCALL   PRINTSTRZ
        STS     F_ADDR0,NULL
        STS     F_ADDR1,NULL
        STS     F_ADDR2,NULL
F12:
        RCALL   NEXTSEC
        STS     LASTSECFLAG,DATA

        LDIX    BUFSECT
        LDS     YL,F_ADDR0
        LDS     YH,F_ADDR1
        LDS     ZL,F_ADDR2

        MOV     DATA,YL
        OR      DATA,YH
        ANDI    DATA,$3F
        BRNE    F11
        LDI     DATA,$23 ;"#"
        RCALL   WRUART
F11:
        RCALL   F_WRITE
        ADIW    YL,1
        ADC     ZL,NULL
        ADIW    XL,1
        CPI     XH,HIGH(BUFSECT+512)
        BRNE    F11

        STS     F_ADDR0,YL
        STS     F_ADDR1,YH
        STS     F_ADDR2,ZH
;св.диод - мигать при программировании
        SBI     PORTB,7
        SBRC    YH,1
        CBI     PORTB,7

        LDS     DATA,LASTSECFLAG
        TST     DATA
        BRNE    F12

        RCALL   F_RST
        LDIZ    MSG_F_COMPLETE*2
        RCALL   PRINTSTRZ
STOP1:  RJMP    STOP1

;
;--------------------------------------
;out:   DATA
SD_RECEIVE:
        SER     DATA
; - - - - - - - - - - - - - - - - - - -
;in:    DATA
;out:   DATA
SD_EXCHANGE:
        OUT     SPDR,DATA
SDEXCH: IN      R0,SPSR
        SBRS    R0,SPIF
        RJMP    SDEXCH
        IN      DATA,SPDR
        RET
;
;--------------------------------------
;in;    TEMP - n
SD_RD_DUMMY:
        SER     DATA
        RCALL   SD_EXCHANGE
        DEC     TEMP
        BRNE    SD_RD_DUMMY
        RET
;
;--------------------------------------
;in:    Z
SD_WR_PGM_6:
        LDI     TEMP,6
SD_WR_PGX:
SDWRP61:ELPM    DATA,Z+
        RCALL   SD_EXCHANGE
        DEC     TEMP
        BRNE    SDWRP61
; - - - - - - - - - - - - - - - - - - -
;out:   DATA
SD_WAIT_NOTFF:
        LDI     TEMP,32
SDWNFF2:SER     DATA
        RCALL   SD_EXCHANGE
        CPI     DATA,$FF
        BRNE    SDWNFF1
        DEC     TEMP
        BRNE    SDWNFF2
SDWNFF1:RET
;
;--------------------------------------
;in:    Z - куда
;       Y,X - №сектора
SD_READ_SECTOR:
        PUSHZ
        LDIZ    CMD58*2
        RCALL   SD_WR_PGM_6
        RCALL   SD_RECEIVE
        SBRC    DATA,6
        RJMP    SDRDSE1
        LSL     XL
        ROL     XH
        ROL     YL
        MOV     YH,YL
        MOV     YL,XH
        MOV     XH,XL
        CLR     XL
SDRDSE1:
        LDI     TEMP,3
        RCALL   SD_RD_DUMMY

        LDI     DATA,CMD_17
        RCALL   SD_EXCHANGE
        MOV     DATA,YH
        RCALL   SD_EXCHANGE
        MOV     DATA,YL
        RCALL   SD_EXCHANGE
        MOV     DATA,XH
        RCALL   SD_EXCHANGE
        MOV     DATA,XL
        RCALL   SD_EXCHANGE
        SER     DATA
        RCALL   SD_EXCHANGE

        SER     R24
SDRDSE2:RCALL   SD_WAIT_NOTFF
        DEC     R24
        BREQ    SDRDSE8
        CPI     DATA,$FE
        BRNE    SDRDSE2

        POPZ
        LDI     R24,$00
        LDI     R25,$02
SDRDSE3:RCALL   SD_RECEIVE
        ST      Z+,DATA
        SBIW    R24,1
        BRNE    SDRDSE3

        LDI     TEMP,2
        RCALL   SD_RD_DUMMY
SDRDSE4:RCALL   SD_WAIT_NOTFF
        CPI     DATA,$FF
        BRNE    SDRDSE4
        RET

SDRDSE8:
       LDI     DATA,2  ;ошибка при чтении сектора
        RJMP    SD_ERROR
;
;--------------------------------------
;
LOAD_DATA:
        LDIZ    BUFSECT
        RCALL   SD_READ_SECTOR  ;читать один сектор
        RET
;
;--------------------------------------
;
LOADLST:LDIZ    BUF4FAT
        RCALL   SD_READ_SECTOR  ;читать один сектор
        LDIZ    BUF4FAT
        RET
;
;--------------------------------------
;чтение сектора dir по номеру описателя (Y)
;на выходе: DATA=#ff (sreg.Z=0) выход за пределы dir
RDDIRSC:PUSHY
        MOVW    XL,YL
        LDIY    0
        LDI     DATA,$10
        RCALL   BCDE_A
        PUSH    XL
        LDS     DATA,BYTSSEC
        PUSH    DATA
        RCALL   BCDE_A
        LDS     DATA,KCLSDIR
        DEC     DATA
        CP      DATA,XL
        BRCC    RDDIRS3
        POP     YL
        POP     YL
        POPY
        SER     DATA
        TST     DATA
        RET
RDDIRS3:LDSY    TEK_DIR+2
        MOV     DATA,XL
        TST     DATA
        LDSX    TEK_DIR+0
        BREQ    RDDIRS1
RDDIRS2:PUSH    DATA
        RCALL   RDFATZP
        POP     DATA
        DEC     DATA
        BRNE    RDDIRS2
RDDIRS1:RCALL   REALSEC
        POP     R0
        DEC     R0
        POP     DATA
        AND     DATA,R0
        ADD     XL,DATA
        ADC     XH,NULL
        ADC     YL,NULL
        ADC     YH,NULL
        RCALL   LOADLST
        POPY
        CLR     DATA
        RET
;
;--------------------------------------
;
LST_CLS:LDS     DATA,CAL_FAT
        TST     DATA
        BRNE    LST_CL1
        CPI     XH,$0F
        BRNE    LST_NO
        CPI     XL,$FF
        RET
LST_CL1:DEC     DATA
        BRNE    LST_CL2
        CPI     XH,$FF
        BRNE    LST_NO
        CPI     XL,$FF
        RET
LST_CL2:CPI     YH,$0F
        BRNE    LST_NO
        CPI     YL,$FF
        BRNE    LST_NO
        CPI     XH,$FF
        BRNE    LST_NO
        CPI     XL,$FF
LST_NO: RET
;
;--------------------------------------
;
RDFATZP:LDS     DATA,CAL_FAT
        TST     DATA
        BREQ    RDFATS0         ;FAT12
        DEC     DATA
        BREQ    RDFATS1         ;FAT16
;FAT32
        LSL     XL
        ROL     XH
        ROL     YL
        ROL     YH
        MOV     DATA,XL
        MOV     XL,XH
        MOV     XH,YL
        MOV     YL,YH
        CLR     YH
        RCALL   RDFATS2
        ADIW    ZL,1
        LD      YL,Z+
        LD      YH,Z
        RET
;FAT16
RDFATS1:LDIY    0
        MOV     DATA,XL
        MOV     XL,XH
        CLR     XH
RDFATS2:PUSH    DATA
        PUSHY
        LDIZ    FATSTR0
        RCALL   BCDEHLP
        RCALL   LOADLST
        POPY
        POP     DATA
        ADD     ZL,DATA
        ADC     ZH,NULL
        ADD     ZL,DATA
        ADC     ZH,NULL
        LD      XL,Z+
        LD      XH,Z
        RET
;FAT12
RDFATS0:MOVW    ZL,XL
        LSL     ZL
        ROL     ZH
        ADD     ZL,XL
        ADC     ZH,XH
        LSR     ZH
        ROR     ZL
        MOV     DATA,XL
        MOV     XL,ZH
        CLR     XH
        CLR     YL
        CLR     YH
        LSR     XL
        PUSH    DATA
        PUSHZ
        LDIZ    FATSTR0
        RCALL   BCDEHLP
        RCALL   LOADLST
        POPY
        ANDI    YH,$01
        ADD     ZL,YL
        ADC     ZH,YH
        LD      YL,Z+
        CPI     ZH,HIGH(BUF4FAT+512)
        BRNE    RDFATS4
        PUSH    YL
        LDIY    0
        ADIW    XL,1
        RCALL   LOADLST
        POP     YL
RDFATS4:POP     DATA
        LD      XH,Z
        MOV     XL,YL
        LDIY    0
        LSR     DATA
        BRCC    RDFATS3
        LSR     XH
        ROR     XL
        LSR     XH
        ROR     XL
        LSR     XH
        ROR     XL
        LSR     XH
        ROR     XL
RDFATS3:ANDI    XH,$0F
        RET
;
;--------------------------------------
;вычисление реального сектора
;на входе YX==номер FAT
;на выходе YX==адрес сектора
REALSEC:MOV     DATA,YH
        OR      DATA,YL
        OR      DATA,XH
        OR      DATA,XL
        BRNE    REALSE1
        LDIZ    FATSTR1
        LDSX    SEC_FAT+0
        LDSY    SEC_FAT+2
        RJMP    BCDEHLP
REALSE1:SBIW    XL,2            ;номер кластера-2
        SBC     YL,NULL
        SBC     YH,NULL
        LDS     DATA,BYTSSEC
        RJMP    REALSE2
REALSE3:LSL     XL
        ROL     XH
        ROL     YL
        ROL     YH
REALSE2:LSR     DATA
        BRCC    REALSE3
                                ;умножили на размер кластера
        LDIZ    STARTRZ
        RCALL   BCDEHLP         ;прибавили смещение от начала диска
        LDIZ    FRSTDAT
        RJMP    BCDEHLP         ;прибавили смещение от начала раздела
;
;--------------------------------------
;YX>>9 (деление на 512)
BCDE200:MOV     XL,XH
        MOV     XH,YL
        MOV     YL,YH
        LDI     YH,0
        LDI     DATA,1
; - - - - - - - - - - - - - - - - - - -
;YXDATA>>до"переноса"
;если в DATA вкл.только один бит, то получается
;YX=YX/DATA
BCDE_A1:LSR     YH
        ROR     YL
        ROR     XH
        ROR     XL
BCDE_A: ROR     DATA
        BRCC    BCDE_A1
        RET
;
;--------------------------------------
;YX=[Z]-YX
BCDEHLM:LD      DATA,Z+
        SUB     DATA,XL
        MOV     XL,DATA
        LD      DATA,Z+
        SBC     DATA,XH
        MOV     XH,DATA
        LD      DATA,Z+
        SBC     DATA,YL
        MOV     YL,DATA
        LD      DATA,Z
        SBC     DATA,YH
        MOV     YH,DATA
        RET
;
;--------------------------------------
;YX=YX+[Z]
BCDEHLP:LD      DATA,Z+
        ADD     XL,DATA
        LD      DATA,Z+
        ADC     XH,DATA
        LD      DATA,Z+
        ADC     YL,DATA
        LD      DATA,Z
        ADC     YH,DATA
        RET
;
;--------------------------------------
;YX=YX+R25R24
HLDEPBC:ADD     XL,R24
        ADC     XH,R25
        ADC     YL,NULL
        ADC     YH,NULL
        RET
;
;--------------------------------------
;
RASCHET:RCALL   BCDE200
        LDIZ    SEC_FAT
        RCALL   BCDEHLM
        MOV     DATA,XL
        ANDI    DATA,$F0
        OR      DATA,XH
        OR      DATA,YL
        OR      DATA,YH
        RET
;
;--------------------------------------
;out:   DATA == 0 - считан последний сектор файла
NEXTSEC:
        SS_SET
        LDI     DATA,SD_DATA
        OUT     SPDR,DATA
NEXTSE1:IN      R0,SPSR
        SBRS    R0,SPIF
        RJMP    NEXTSE1
        IN      R0,SPDR
        SS_CLR

        LDIZ    KOL_CLS
        LD      DATA,Z+
        LD      TEMP,Z+
        OR      DATA,TEMP
        LD      TEMP,Z+
        OR      DATA,TEMP
        LD      TEMP,Z+
        OR      DATA,TEMP
        BREQ    LSTCLSF
        LDSX    TFILCLS+0
        LDSY    TFILCLS+2
        RCALL   REALSEC
        LDS     DATA,NUMSECK
        ADD     XL,DATA
        ADC     XH,NULL
        ADC     YL,NULL
        ADC     YH,NULL
        RCALL   LOAD_DATA
        LDSX    TFILCLS+0
        LDSY    TFILCLS+2
        LDS     DATA,NUMSECK
        INC     DATA
        STS     NUMSECK,DATA
        LDS     TEMP,BYTSSEC
        CP      TEMP,DATA
        BRNE    NEXT_OK

        STS     NUMSECK,NULL
        RCALL   RDFATZP
        STSX    TFILCLS+0
        STSY    TFILCLS+2
        LDIZ    KOL_CLS
        LD      DATA,Z
        SUBI    DATA,1
        ST      Z+,DATA
        LD      DATA,Z
        SBC     DATA,NULL
        ST      Z+,DATA
        LD      DATA,Z
        SBC     DATA,NULL
        ST      Z+,DATA
        LD      DATA,Z
        SBC     DATA,NULL
        ST      Z+,DATA
NEXT_OK:SER     DATA
        RET

LSTCLSF:LDSX    TFILCLS+0
        LDSY    TFILCLS+2
        RCALL   REALSEC
        LDS     DATA,NUMSECK
        ADD     XL,DATA
        ADC     XH,NULL
        ADC     YL,NULL
        ADC     YH,NULL
        RCALL   LOAD_DATA
        LDS     DATA,NUMSECK
        INC     DATA
        STS     NUMSECK,DATA
        LDS     TEMP,MPHWOST
        SUB     DATA,TEMP
        RET
;
;--------------------------------------
;
SD_ERROR:
        STS     SDERROR,DATA
        LDI     TEMP,LOW(RAMEND)
        OUT     SPL,TEMP
        LDI     TEMP,HIGH(RAMEND)
        OUT     SPH,TEMP

        LDIZ    MSG_SDERROR*2
        RCALL   PRINTSTRZ
        LDS     DATA,SDERROR
        CPI     DATA,1
        BRNE    SD_ERR2
        LDIZ    MSG_CARD*2
        RCALL   PRINTSTRZ
        RJMP    SD_NOTFOUND
SD_ERR2:
        CPI     DATA,2
        BRNE    SD_ERR3
        LDIZ    MSG_READERROR*2
        RCALL   PRINTSTRZ
        RJMP    SD_ERR9
SD_ERR3:
        CPI     DATA,3
        BRNE    SD_ERR4
        LDIZ    MSG_FAT*2
        RCALL   PRINTSTRZ
        RJMP    SD_NOTFOUND
SD_ERR4:
        CPI     DATA,4
        BRNE    SD_ERR5
        LDIZ    MSG_FILE*2
        RCALL   PRINTSTRZ
SD_NOTFOUND:
        LDIZ    MSG_NOTFOUND*2
        RCALL   PRINTSTRZ
        RJMP    SD_ERR9
SD_ERR5:
        CPI     DATA,5
        BRNE    SD_ERR6
        LDIZ    MSG_FILE*2
        RCALL   PRINTSTRZ
        LDIZ    MSG_EMPTY*2
        RCALL   PRINTSTRZ
        RJMP    SD_ERR9
SD_ERR6:
        LDIZ    MSG_FILE*2
        RCALL   PRINTSTRZ
        LDIZ    MSG_TOOBIG*2
        RCALL   PRINTSTRZ
SD_ERR9:
;
        LDS     ZL,SDERROR
SD_ERR1:CBI     PORTB,7
        LDI     DATA,5
        RCALL   BEEP
        SBI     PORTB,7
        LDI     DATA,5
        RCALL   DELAY
        DEC     ZL
        BRNE    SD_ERR1
;
        LDIZ    MSG_F_AGAIN*2
        RCALL   PRINTSTRZ
        RCALL   SOFTBUTTON
        JMP     START
;
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
        LDI     ZL,$00
        RCALL   F_IN
        MOV     XL,DATA
        LDI     YL,$01
        RCALL   F_IN
        MOV     XH,DATA
        RJMP    F_RST
;
;--------------------------------------
;in:    [X] - data
;       YL,YH,ZL - address
F_WRITE:LDI     DATA,$A0
        RCALL   F_CMD
        LD      DATA,X
        RCALL   F_OUT
        LDI     TEMP,FLASH_CTRL
        LDI     DATA,0B00000011
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_DATA
        RCALL   FPGA_REG
F_WRIT1:RCALL   FPGA_SAME_REG
        LD      TEMP,X
        EOR     DATA,TEMP
        SBRC    DATA,7
        RJMP    F_WRIT1
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
        LDI     TEMP,FLASH_DATA
        RCALL   FPGA_REG
F_ERAS1:SBI     PORTB,7 ;св.диод погасить
        RCALL   FPGA_SAME_REG
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
;in:    YL,YH,ZL - address
;out:   DATA - data
F_IN:
        LDI     TEMP,FLASH_LOADDR
        MOV     DATA,YL
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_MIDADDR
        MOV     DATA,YH
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_HIADDR
        MOV     DATA,ZL
        RCALL   FPGA_REG
        LDI     TEMP,FLASH_DATA
        LDI     DATA,$FF
        RJMP    FPGA_REG
;
;--------------------------------------
;in:    YL,YH,ZL - address
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
        RJMP    RD_WHEN_RDY
;
RD_WHEN_RDY:
        IN      R0,SPSR
        SBRS    R0,SPIF
        RJMP    RD_WHEN_RDY
        IN      DATA,SPDR
        SS_SET
        RET
;
;--------------------------------------
;
SOFTBUTTON:
        SBIS    PINC,7
        RJMP    SOFTBUTTON
SOFTB2: SBIC    PINC,7
        RJMP    SOFTB2
        RET
;
;--------------------------------------
;PRINTSTRZ
;in:    Z == указательна строку (в старших 64K)
PRINTSTRZ:
PRSTRZ1:ELPM    DATA,Z+
        TST     DATA
        BREQ    PRSTRZ2
        RCALL   WRUART
        RJMP    PRSTRZ1
PRSTRZ2:RET
;
;--------------------------------------
;byte in dec to uart
;in:    DATA == byte (0..99)
DECBYTE:SUBI    DATA,208
        SBRS    DATA,7
        SUBI    DATA,48
        SUBI    DATA,232
        SBRS    DATA,6
        SUBI    DATA,24
        SUBI    DATA,244
        SBRS    DATA,5
        SUBI    DATA,12
        SUBI    DATA,250
        SBRS    DATA,4
        SUBI    DATA,6
;
; - - - - - - - - - - - - - - - - - - -
;byte in hex to uart
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
;WRUART
;in:    DATA == передаваемый байт
WRUART: PUSH    TEMP
WRU_1:  INPORT  TEMP,UCSR1A
        SBRS    TEMP,UDRE
        RJMP    WRU_1
        OUTPORT UDR1,DATA
        POP     TEMP
        RET
;
;--------------------------------------
;in:    DATA - длительность *0.1s
BEEP:
BEE2:   LDI     TEMP,100;100 периодов 1кГц
BEE1:   CBI     PORTE,6
        RCALL   BEEPDLY
        SBI     PORTE,6
        RCALL   BEEPDLY
        DEC     TEMP
        BRNE    BEE1
        DEC     DATA
        BRNE    BEE2
        RET

BEEPDLY:LDI     R24,$64
        LDI     R25,$05
BEEPDL1:SBIW    R24,1
        BRNE    BEEPDL1
        RET
;
;--------------------------------------
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
CMD00:  .DB     $40,$00,$00,$00,$00,$95
CMD08:  .DB     $48,$00,$00,$01,$AA,$87
CMD16:  .DB     $50,$00,$00,$02,$00,$FF
CMD55:  .DB     $77,$00,$00,$00,$00,$FF ;app_cmd
CMD58:  .DB     $7A,$00,$00,$00,$00,$FF ;read_ocr
CMD59:  .DB     $7B,$00,$00,$00,$00,$FF ;crc_on_off
FILENAME:
        .DB     "ZXEVO   ROM",0

MSG_TITLE:
        .DB     $0D,$0A,$0A,$0A,$0A,"-------------------------"
        .DB     $0D,$0A,"ZX Evolution Flasher v0.0",0
MSG_POWERON:
        .DB     $0D,$0A,"ATX power up...",0
MSG_CFGFPGA:
        .DB     $0D,$0A,"Set temporary configuration...",0,0
MSG_ID_FLASH:
        .DB     $0D,$0A,"ID flash memory chip: ",0,0
MSG_OPENFILE:
        .DB     $0D,$0A,"Open file from SD-card...",0
MSG_SDERROR:
        .DB     $0D,$0A,"SD error: ",0,0
MSG_CARD:
        .DB     "Card",0,0
MSG_READERROR:
        .DB     "Read error",0,0
MSG_FAT:
        .DB     "FAT",0
MSG_FILE:
        .DB     "File ZXEVO.ROM",0,0
MSG_NOTFOUND:
        .DB     " not found",0,0
MSG_EMPTY:
        .DB     " empty",0,0
MSG_TOOBIG:
        .DB     " too big",0,0
MSG_F_AGAIN:
        .DB     $0D,$0A,$0A,"1) Change SD-card"
        .DB     $0D,$0A,"2) Press 'SoftReset' button.",0,0

MSG_F_CONFIRM:
        .DB     $0D,$0A,"To confirm programming, press 'SoftReset' button.",0
MSG_F_ERASE:
        .DB     $0D,    "Erase  EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE          ",0,0
MSG_F_WRITE:
        .DB     $0D,    "Write  ::::::::::::::::::::::::::::::::",$0D,"Write  ",0,0
MSG_F_COMPLETE:
        .DB     $0D,$0A,"Complete!",$0A
        .DB     $0D,$0A,"1) Change SD-card "
        .DB     $0D,$0A,"2) Hold 'SoftReset' button and press 'HardReset' button shortly.",0,0
;
PACKED_FPGA:
.NOLIST
.INCLUDE "FPGA.INC"
.LIST
        .ORG    LARGEBOOTSTART-1
CRC:    .DW     0
