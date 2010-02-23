#ifndef __MAIN_H__
#define __MAIN_H__

/**
 * @mainpage  General program for ATMEGA128 ZX Evolution.
 *
 * @section history Revision history
 *
 * @subsection current Current version.
 * - Fix mapping gluk (DS12887) nvram to PCF8583.
 * - Fix Update Flag in register C (emulation Gluk clock).
 * - Add modes register and save/restore it to RTC NVRAM.
 * - Add support for zx (mechanical) keyboard.
 * - Add support for Kempston joystick.
 *
 * @subsection ver_1_00 Version 1.00 - base version.
 *
 */

/**
 * @file
 * @brief Main module.
 * @author http://www.nedopc.com
 */

/** Common flag register. */
extern volatile UBYTE flags_register;
/** Direction for ps2 mouse data (0 - Receive/1 - Send). */
#define FLAG_PS2MOUSE_DIRECTION 0x01
/** Type of ps2 mouse (0 - classical [3bytes in packet]/1 - msoft [4bytes in packet]). */
#define FLAG_PS2MOUSE_TYPE      0x02
/** Ps2 mouse data for zx (0 - not ready/1 - ready). */
#define FLAG_PS2MOUSE_ZX_READY  0x04
/** Spi interrupt detected (0 - not received/1 - received). */
#define FLAG_SPI_INT            0x08

/** Common modes register. */
extern volatile UBYTE modes_register;
/** VGA mode (0 - not set/1 - set). */
#define MODE_VGA 0x01

/** Data buffer. */
extern UBYTE dbuf[];

/** Input data */
extern ULONG indata;

/**
 * Writes specified length of buffer to SPI.
 * @param size [in] - size of buffer.
 */
void put_buffer(UWORD size);


#endif //__MAIN_H__
