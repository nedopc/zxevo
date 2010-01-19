#ifndef PS2_H
#define PS2_H

#include "mytypes.h"

// ============  ps2 common ===================

extern volatile UBYTE ps2_flags;
#define PS2MOUSE_DIRECTION_FLAG 0x01 //direction for data 0 - Receive/1 - Send
#define PS2MOUSE_TYPE_FLAG      0x02 //type mouse 0 - classical (3bytes in packet)/1 - msoft (4bytes in packet)
#define PS2MOUSE_ZX_READY_FLAG  0x04 //data for zx 0 - not ready/1 - ready

/**
 * Decode received data.
 * @return decoded data.
 * @par count - counter.
 * @par shifter - received bits.
 */
UBYTE ps2_decode(UBYTE count, UWORD shifter);
/**
 * Encode (prepare) sended data.
 * @return encoded data.
 * @par data - data to send.
 */
UWORD ps2_encode(UBYTE data);

//=======  ps2 keyboard  ================

extern volatile UWORD ps2keyboard_shifter;
extern volatile UBYTE ps2keyboard_count;
extern volatile UBYTE ps2keyboard_timeout;

#define PS2KEYBOARD_TIMEOUT 20

void ps2keyboard_task(void); // main entry function
void ps2keyboard_parse(UBYTE);

//=======  ps2 mouse  ================

//timeout for waiting response from mouse
#define PS2MOUSE_TIMEOUT 20

extern volatile UWORD ps2mouse_shifter; //content received/sended data
extern volatile UBYTE ps2mouse_count;  //counter for current received/sended bit
extern volatile UBYTE ps2mouse_timeout;
extern volatile UBYTE ps2mouse_initstep;
extern volatile UBYTE ps2mouse_resp_count;

//void ps2mouse_init(void);
void ps2mouse_task(void);

#endif //PS2_H

