#ifndef PS2_H
#define PS2_H

#include "mytypes.h"

// ============  ps2 common ===================

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

/** Timeout for waiting response from mouse. */
#define PS2MOUSE_TIMEOUT 20

/** Received/sended PS/2 mouse data register.*/
extern volatile UWORD ps2mouse_shifter;

/** Counter of current received/sended PS/2 mouse data bit.*/
extern volatile UBYTE ps2mouse_count;

/** Timeout register for detecting send/response PS/2 mouse timeouts.*/
extern volatile UBYTE ps2mouse_timeout;

/** Index of PS/2 mouse initialization step (@see ps2mouse_init_sequence).*/
extern volatile UBYTE ps2mouse_initstep;

/** Counter of PS/2 mouse response bytes.*/
extern volatile UBYTE ps2mouse_resp_count;

/** Check and translate data from PS/2 mouse.*/
void ps2mouse_task(void);

#endif //PS2_H

