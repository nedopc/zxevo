.NOLIST
.INCLUDE "M128DEF.INC"
.INCLUDE "_MACROS.ASM"

.MACRO  SDCS_SET
        SBI     PORTB,0
.ENDMACRO

.MACRO  SDCS_CLR
        CBI     PORTB,0
.ENDMACRO

.MACRO  LED_ON
        CBI     PORTB,7
.ENDMACRO

.MACRO  LED_OFF
        SBI     PORTB,7
.ENDMACRO

.LIST
.LISTMAC

.DEF    POLY_LO =R06    ;всегда = $21
.DEF    POLY_HI =R07    ;всегда = $10
.DEF    FF_FL   =R08
.DEF    CRC_LO  =R09
.DEF    CRC_HI  =R10
.DEF    ADR1    =R11
.DEF    ADR2    =R12
.DEF    FF      =R13    ;всегда = $FF
.DEF    ONE     =R14    ;всегда = $01
.DEF    NULL    =R15    ;всегда = $00
.DEF    DATA    =R16
.DEF    TEMP    =R17
.DEF    COUNT   =R18
.DEF    BITS    =R19
.DEF    GUARD   =R22
;локально используются: R0,R1,R20,R21,R24,R25

.EQU    DBSIZE_HI       =HIGH(4096)
.EQU    DBMASK_HI       =HIGH(4095)
.EQU    nCONFIG         =PORTF0
.EQU    nSTATUS         =PORTF1
.EQU    CONF_DONE       =PORTF2

.EQU    CMD_17          =$51    ;read_single_block
.EQU    ACMD_41         =$69    ;sd_send_op_cond

;--------------------------------------
;
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
STEP:
SDERROR:.BYTE   1
LASTSECFLAG:
        .BYTE   1
;
;--------------------------------------
;
.CSEG
        .ORG    $0000
START1: CLI
        CLR     NULL
        LDI     TEMP,$01
        MOV     ONE,TEMP
        LDI     TEMP,$FF
        MOV     FF,TEMP
        LDI     TEMP,$21
        MOV     POLY_LO,TEMP
        LDI     TEMP,$10
        MOV     POLY_HI,TEMP

       OUT     MCUCSR,NULL
;
;WatchDog OFF, если вдруг включен
        LDI     TEMP,0B00011111
        OUT     WDTCR,TEMP
        OUT     WDTCR,NULL
;
        LED_ON
        SBI     DDRB,7
;стек
        LDI     TEMP,LOW(RAMEND)
        OUT     SPL,TEMP
        LDI     TEMP,HIGH(RAMEND)
        OUT     SPH,TEMP

        LDI     TEMP,      0B11111111
        OUTPORT PORTG,TEMP
        LDI     TEMP,      0B00000000
        OUTPORT DDRG,TEMP

        LDI     TEMP,      0B00001000
        OUTPORT PORTF,TEMP
        OUTPORT DDRF,TEMP

        LDI     TEMP,      0B11111111
        OUT     PORTE,TEMP
        LDI     TEMP,      0B00000000
        OUT     DDRE,TEMP

        LDI     TEMP,      0B11111111
        OUT     PORTD,TEMP
        LDI     TEMP,      0B00000000
        OUT     DDRD,TEMP

        LDI     TEMP,      0B11011111
        OUT     PORTC,TEMP
        LDI     TEMP,      0B00000000
        OUT     DDRC,TEMP

        LDI     TEMP,      0B11111001
        OUT     PORTB,TEMP
        LDI     TEMP,      0B10000111
        OUT     DDRB,TEMP

        LDI     TEMP,      0B11111111
        OUT     PORTA,TEMP
        LDI     TEMP,      0B00000000
        OUT     DDRA,TEMP

;SPI init
        LDI     TEMP,(1<<SPI2X)
        OUT     SPSR,TEMP
        LDI     TEMP,(1<<SPE)|(1<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)
        OUT     SPCR,TEMP
;UART1 Set baud rate
        OUTPORT UBRR1H,NULL
        LDI     TEMP,5     ;115200 baud @ 11059.2 kHz, Normal speed
        OUTPORT UBRR1L,TEMP
;UART1 Normal Speed
        OUTPORT UCSR1A,NULL
;UART1 data8bit, 2stopbits
        LDI     TEMP,(1<<UCSZ1)|(1<<UCSZ0)|(1<<USBS)
        OUTPORT UCSR1C,TEMP
;UART1 Разрешаем передачу
        LDI     TEMP,(1<<TXEN)
        OUTPORT UCSR1B,TEMP

;ждём включения ATX, а потом ещё чуть-чуть.
UP11:   SBIS    PINF,0 ;PINC,5 ; а если powergood нет вообще ?
        RJMP    UP11
        LDI     DATA,5
        RCALL   DELAY

;загрузка FPGA
        INPORT  TEMP,DDRF
        SBR     TEMP,(1<<nCONFIG)
        OUTPORT DDRF,TEMP

        LDI     TEMP,147 ;40 us @ 11.0592 MHz
LDFPGA1:DEC     TEMP    ;1
        BRNE    LDFPGA1 ;2

        INPORT  TEMP,DDRF
        CBR     TEMP,(1<<nCONFIG)
        OUTPORT DDRF,TEMP

LDFPGA2:SBIS    PINF,nSTATUS
        RJMP    LDFPGA2

        LDIZ    PACKED_FPGA*2
        LDIY    BUFFER
;(не трогаем стек! всё ОЗУ под буфер)
        LDI     TEMP,$80
MS:     LPM     R0,Z+
        ST      Y+,R0
;-begin-PUT_BYTE_1---
        OUT     SPDR,R0
PUTB1:  SBIS    SPSR,SPIF
        RJMP    PUTB1
;-end---PUT_BYTE_1---
        SUBI    YH,HIGH(BUFFER) ;
        ANDI    YH,DBMASK_HI    ;Y warp
        ADDI    YH,HIGH(BUFFER) ;
M0:     LDI     R21,$02
        LDI     R20,$FF
M1:
M1X:    ADD     TEMP,TEMP
        BRNE    M2
        LPM     TEMP,Z+
        ROL     TEMP
M2:     ROL     R20
        BRCC    M1X
        DEC     R21
        BRNE    X2
        LDI     DATA,2
        ASR     R20
        BRCS    N1
        INC     DATA
        INC     R20
        BREQ    N2
        LDI     R21,$03
        LDI     R20,$3F
        RJMP    M1
X2:     DEC     R21
        BRNE    X3
        LSR     R20
        BRCS    MS
        INC     R21
        RJMP    M1
X6:     ADD     DATA,R20
N2:     LDI     R21,$04
        LDI     R20,$FF
        RJMP    M1
N1:     INC     R20
        BRNE    M4
        INC     R21
N5:     ROR     R20
        BRCS    DEMLZEND
        ROL     R21
        ADD     TEMP,TEMP
        BRNE    N6
        LPM     TEMP,Z+
        ROL     TEMP
N6:     BRCC    N5
        ADD     DATA,R21
        LDI     R21,6
        RJMP    M1
X3:     DEC     R21
        BRNE    X4
        LDI     DATA,1
        RJMP    M3
X4:     DEC     R21
        BRNE    X5
        INC     R20
        BRNE    M4
        LDI     R21,$05
        LDI     R20,$1F
        RJMP    M1
X5:     DEC     R21
        BRNE    X6
        MOV     R21,R20
M4:     LPM     R20,Z+
M3:     DEC     R21
        MOV     XL,R20
        MOV     XH,R21
        ADD     XL,YL
        ADC     XH,YH
LDIRLOOP:
        SUBI    XH,HIGH(BUFFER) ;
        ANDI    XH,DBMASK_HI    ;X warp
        ADDI    XH,HIGH(BUFFER) ;
        LD      R0,X+
        ST      Y+,R0
;-begin-PUT_BYTE_2---
        OUT     SPDR,R0
PUTB2:  SBIS    SPSR,SPIF
        RJMP    PUTB2
;-end---PUT_BYTE_2---
        SUBI    YH,HIGH(BUFFER) ;
        ANDI    YH,DBMASK_HI    ;Y warp
        ADDI    YH,HIGH(BUFFER) ;
        DEC     DATA
        BRNE    LDIRLOOP
        RJMP    M0
;теперь можно юзать стек
DEMLZEND:
        SBIS    PINF,CONF_DONE
        RJMP    DEMLZEND
;SPI reinit
        LDI     TEMP,(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)
        OUT     SPCR,TEMP
        LED_OFF
; - - - - - - - - - - - - - - - - - - -
        LDIZ    MSG_START*2
        RCALL   PRINTSTRZ
        LDIZ    LARGEBOOTSTART*2-4
        OUT     RAMPZ,ONE
        ELPM    XL,Z+
        ELPM    XH,Z
        MOV     DATA,XL
        ANDI    DATA,$1F
        BREQ    PRVERS8
        MOV     TEMP,XH
        LSL     XL
        ROL     TEMP
        LSL     XL
        ROL     TEMP
        LSL     XL
        ROL     TEMP
        ANDI    TEMP,$0F
        BREQ    PRVERS8
        CPI     TEMP,13
        BRCC    PRVERS8
        MOV     COUNT,XH
        LSR     COUNT
        ANDI    COUNT,$3F
        CPI     COUNT,9
        BRCS    PRVERS8
        PUSH    DATA
        LDI     DATA,$28 ;"("
        RCALL   WRUART
        MOV     DATA,COUNT
        RCALL   DECBYTE
        MOV     DATA,TEMP
        RCALL   DECBYTE
        POP     DATA
        RCALL   DECBYTE
        LDI     DATA,$29 ;")"
        RCALL   WRUART
        RJMP    PRVERS9
PRVERS8:LDI     DATA,$20 ;" "
        LDI     COUNT,8
PRVERS7:RCALL   WRUART
        DEC     COUNT
        BREQ    PRVERS7
PRVERS9:
;
;--------------------------------------
;инициализация SD карточки
       LDIZ    MSG_CS_UP*2
       RCALL   PRINTSTRZ
        SDCS_SET
        LDI     TEMP,32
        RCALL   SD_RD_DUMMY
       LDIZ    MSG_CS_DOWN*2
       RCALL   PRINTSTRZ
        SDCS_CLR
        SER     R24
SDINIT1:
       LDIZ    MSG_CMD00*2
       RCALL   PRINTSTRZ
        LDIZ    CMD00*2
        RCALL   SD_WR_PGM_6
        DEC     R24
        BRNE    SDINIT2
        LDI     DATA,1  ;нет SD
        RJMP    SD_ERROR
SDINIT2:CPI     DATA,$01
        BRNE    SDINIT1
       LDIZ    MSG_CMD08*2
       RCALL   PRINTSTRZ
        LDIZ    CMD08*2
        RCALL   SD_WR_PGM_6
        LDI     R24,$00
        SBRS    DATA,2
        LDI     R24,$40
        LDI     TEMP,4
        RCALL   SD_RD_DUMMY
SDINIT3:
       LDIZ    MSG_CMD55*2
       RCALL   PRINTSTRZ
        LDIZ    CMD55*2
        RCALL   SD_WR_PGM_6
       LDIZ    MSG_ACMD41*2
       RCALL   PRINTSTRZ
        LDI     TEMP,2
        RCALL   SD_RD_DUMMY
        LDI     DATA,ACMD_41
        RCALL   SD_EXCHANGE
        MOV     DATA,R24
        RCALL   SD_EXCHANGE

        LDIZ    CMD55*2+2
        LDI     TEMP,4
        RCALL   SD_WR_PGX
        TST     DATA

        BRNE    SDINIT3

;        BREQ    SDINIT4
;        SBRS    DATA,2
;        RJMP    SDINIT3
;
;SDINIT6:
;       LDIZ    MSG_CMD01*2
;       RCALL   PRINTSTRZ
;        LDIZ    CMD01*2
;        RCALL   SD_WR_PGM_6
;        TST     DATA
;        BRNE    SDINIT6

SDINIT4:
       LDIZ    MSG_CMD59*2
       RCALL   PRINTSTRZ
        LDIZ    CMD59*2
        RCALL   SD_WR_PGM_6
        TST     DATA
        BRNE    SDINIT4

SDINIT5:
       LDIZ    MSG_CMD16*2
       RCALL   PRINTSTRZ
        LDIZ    CMD16*2
        RCALL   SD_WR_PGM_6
        TST     DATA
        BRNE    SDINIT5

       LDIZ    MSG_CS_UP*2
       RCALL   PRINTSTRZ
        SDCS_SET
;
;--------------------------------------
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
        CPI     DATA,$04
        BREQ    RDFAT06
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
        BRCC    LASTCLS
        INC     TEMP
        RJMP    NEXTCLS
LASTCLS:STS     KCLSDIR,TEMP
        LDIY    0
        RCALL   RDDIRSC
;
;--------------------------------------
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
DALSHE: LPM     DATA,Z+
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
;--------------------------------------
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
        LDI     DATA,5  ;ошибка в файле (CRC/signature/length)
        RJMP    SD_ERROR
F01:    LDI     R24,LOW(511)
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
;
;--------------------------------------
;загружаем данные из файла
SDUPD90:RCALL   NEXTSEC
        TST     DATA
        BRNE    SDUPD90

       LDIZ    MSG_CS_UP*2
       RCALL   PRINTSTRZ
        SDCS_SET
       LDIZ    MSG_STOP*2
       RCALL   PRINTSTRZ
SDUPD99:RJMP    SDUPD99

;
;--------------------------------------
;out:   DATA
SD_RECEIVE:
        SER     DATA
; - - - - - - - - - - - - - - - - - - -
;in:    DATA
;out:   DATA
SD_EXCHANGE:
       PUSH    DATA
       LDI     DATA,$01
       RCALL   WRUART
       POP     DATA
       RCALL   WRUART
        OUT     SPDR,DATA
SDEXCH: SBIS    SPSR,SPIF
        RJMP    SDEXCH
        IN      DATA,SPDR
       RCALL   WRUART
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
        LDI     TEMP,2
        RCALL   SD_RD_DUMMY
        LDI     TEMP,6
SD_WR_PGX:
SDWRP61:LPM     DATA,Z+
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
       LDI     DATA,$05
       RCALL   WRUART
       MOV     DATA,YH
       RCALL   WRUART
       MOV     DATA,YL
       RCALL   WRUART
       MOV     DATA,XH
       RCALL   WRUART
       MOV     DATA,XL
       RCALL   WRUART
       LDIZ    MSG_CS_DOWN*2
       RCALL   PRINTSTRZ
       POPZ
        SDCS_CLR

        PUSHZ
       LDIZ    MSG_CMD58*2
       RCALL   PRINTSTRZ
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
        LDI     TEMP,3+2
        RCALL   SD_RD_DUMMY

       PUSHZ
       LDIZ    MSG_CMD17*2
       RCALL   PRINTSTRZ
       POPZ
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

       LDI     DATA,$02
       RCALL   WRUART
SDRDSE3:
;        RCALL   SD_RECEIVE
;--------------------------------------
;SD_RECEIVE:
        SER     DATA
        OUT     SPDR,DATA
SDEXCH2:SBIS    SPSR,SPIF
        RJMP    SDEXCH2
        IN      DATA,SPDR
;--------------------------------------
       RCALL   WRUART
        ST      Z+,DATA
        SBIW    R24,1
        BRNE    SDRDSE3

        LDI     TEMP,2+2
        RCALL   SD_RD_DUMMY
;SDRDSE4:RCALL   SD_WAIT_NOTFF
;        CPI     DATA,$FF
;        BRNE    SDRDSE4

       PUSHZ
       LDIZ    MSG_CS_UP*2
       RCALL   PRINTSTRZ
       POPZ
        SDCS_SET
        RET

SDRDSE8:LDI     DATA,2  ;ошибка при чтении сектора
        RJMP    SD_ERROR
;
;--------------------------------------
;чтение сектора данных
LOAD_DATA:
        LDIZ    BUFSECT
        RCALL   SD_READ_SECTOR  ;читать один сектор
        RET
;
;--------------------------------------
;чтение сектора служ.инф. (FAT/DIR/...)
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
;out:   sreg.C == CLR - EOCmark
;(chng: TEMP)
LST_CLS:LDI     TEMP,$0F
        LDS     DATA,CAL_FAT
        TST     DATA
        BRNE    LST_CL1
        CPI     XL,$F7
        CPC     XH,TEMP
        RET
LST_CL1:DEC     DATA
        BRNE    LST_CL2
        CPI     XL,$F7
        CPC     XH,FF
        RET
LST_CL2:CPI     XL,$F7
        CPC     XH,FF
        CPC     YL,FF
        CPC     YH,TEMP
        RET
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
        ANDI    YH,$0F
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
;чтение очередного сектора файла в BUFSECT
;out:   DATA == 0 - считан последний сектор файла
NEXTSEC:LDIZ    KOL_CLS
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
;ошибка SD
SD_ERROR:
        STS     SDERROR,DATA
        LDI     TEMP,LOW(RAMEND)
        OUT     SPL,TEMP
        LDI     TEMP,HIGH(RAMEND)
        OUT     SPH,TEMP
       LDIZ    MSG_CS_UP*2
       RCALL   PRINTSTRZ
        SDCS_SET

       LDIZ    MSG_ERROR*2
       RCALL   PRINTSTRZ
       LDS     DATA,SDERROR
       RCALL   HEXBYTE

       LDIZ    MSG_STOP*2
       RCALL   PRINTSTRZ
SDERR99:RJMP    SDERR99
;
;--------------------------------------
;in:    Z == указательна строку (в младших 64K)
PRINTSTRZ:
PRSTRZ1:LPM     DATA,Z+
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
;in:    DATA == продолжительность *0.1 сек
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
;--------------------------------------
;
CMD00:  .DB     $40,$00,$00,$00,$00,$95
CMD08:  .DB     $48,$00,$00,$01,$AA,$87
CMD16:  .DB     $50,$00,$00,$02,$00,$FF
CMD01:  .DB     $41,$00,$00,$00,$00,$FF
CMD55:  .DB     $77,$00,$00,$00,$00,$FF ;app_cmd
CMD58:  .DB     $7A,$00,$00,$00,$00,$FF ;read_ocr
CMD59:  .DB     $7B,$00,$00,$00,$00,$FF ;crc_on_off
;
FILENAME:       .DB     "TESTFILEBIN",0
;
MSG_START:
        .DB     $04, 19," SD LOGGER ",0 ;11+8
MSG_CMD00:
        .DB     $04,  5,"CMD00",0
MSG_CMD01:
        .DB     $04,  5,"CMD01",0
MSG_CMD08:
        .DB     $04,  5,"CMD08",0
MSG_CMD17:
        .DB     $04,  5,"CMD17",0
MSG_CMD55:
        .DB     $04,  5,"CMD55",0
MSG_CMD58:
        .DB     $04,  5,"CMD58",0
MSG_ACMD41:
        .DB     $04,  6,"ACMD41",0,0
MSG_CMD59:
        .DB     $04,  5,"CMD59",0
MSG_CMD16:
        .DB     $04,  5,"CMD16",0
MSG_CS_UP:
        .DB     $04,  5,"CS UP",0
MSG_CS_DOWN:
        .DB     $04,  5,"CS DW",0
MSG_STOP:
        .DB     $04,  4,"STOP",0,0
MSG_ERROR:
        .DB     $04,  5,"ERR",0         ;3+2
;
PACKED_FPGA:
.NOLIST
.INCLUDE "FPGA.INC"
.LIST
;
;--------------------------------------
;
