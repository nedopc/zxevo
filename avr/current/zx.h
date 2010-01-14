#ifndef ZX_H
#define ZX_H

#include "mytypes.h"



// key code is 7 bits, 8th bit is press/release (1=press,0=release)
//
// ACHTUNG!!!! DO NOT CHANGE THESE DEFINES, OTHERWISE MUCH OF CODE WILL BREAK!!!!
//
#define PRESS_BIT  7
#define PRESS_MASK 128
#define KEY_MASK   127
//
#define KEY_SP  0
#define KEY_EN  1
#define KEY_P   2
#define KEY_0   3
#define KEY_1   4
#define KEY_Q   5
#define KEY_A   6
#define KEY_CS  7
//
#define KEY_SS  8
#define KEY_L   9
#define KEY_O  10
#define KEY_9  11
#define KEY_2  12
#define KEY_W  13
#define KEY_S  14
#define KEY_Z  15
//
#define KEY_M  16
#define KEY_K  17
#define KEY_I  18
#define KEY_8  19
#define KEY_3  20
#define KEY_E  21
#define KEY_D  22
#define KEY_X  23
//
#define KEY_N  24
#define KEY_J  25
#define KEY_U  26
#define KEY_7  27
#define KEY_4  28
#define KEY_R  29
#define KEY_F  30
#define KEY_C  31
//
#define KEY_B  32
#define KEY_H  33
#define KEY_Y  34
#define KEY_6  35
#define KEY_5  36
#define KEY_T  37
#define KEY_G  38
#define KEY_V  39
//
#define NO_KEY 0x7F
#define RST_48 0x7E
#define RST128 0x7D
#define RSTRDS 0x7C
#define RSTSYS 0x7B
#define CLRKYS 0x7A
//


// SPI registers
//
#define SPI_KBD_DAT   0x80
#define SPI_KBD_STB   0x81
//
#define SPI_MOUSE_X   0x40
#define SPI_MOUSE_Y   0x41
#define SPI_MOUSE_BTN 0x42
//
#define SPI_RST_REG   0x20







// pause between (CS|SS) and not(CS|SS)
#define SHIFT_PAUSE 8
//
extern volatile UBYTE shift_pause;

/*struct zx {
	UBYTE counters[40];
	UBYTE map[5]; // send order: LSbit first, from [4] to [0]
	UBYTE reset_type;
};*/











#define ZX_TASK_INIT 0
#define ZX_TASK_WORK 1

void zx_task(UBYTE operation);

void zx_init(void);

void to_zx(UBYTE scancode, UBYTE was_E0, UBYTE was_release);

void update_keys(UBYTE zxcode, UBYTE was_release);

void zx_clr_kb(void);


void  zx_fifo_put(UBYTE input);
UBYTE zx_fifo_isfull(void);
UBYTE zx_fifo_isempty(void);
UBYTE zx_fifo_get(void);
UBYTE zx_fifo_copy(void);






#endif

