#ifndef __JOYSTICK_H__
#define __JOYSTICK_H__

/**
 * @file
 * @brief Kempstone joystick support.
 * @author http://www.nedopc.com
 *
 * Kempston joystick support for ZX Evolution.
 *
 * Kempston joystick port bits (if bit set - button pressed):
 * 0: left
 * 1: right
 * 2: up
 * 3: down
 * 4: fire
 * 5-7: 0
 */

/** Kempstone joystick task. */
void joystick_task(void);

/** Kempston joystick LEFT buttons bit. */
#define KEMPSTON_JOYSTICK_BIT_LEFT  0x01
/** Kempston joystick RIGHT buttons bit. */
#define KEMPSTON_JOYSTICK_BIT_RIGHT 0x02
/** Kempston joystick UP buttons bit. */
#define KEMPSTON_JOYSTICK_BIT_UP    0x04
/** Kempston joystick DOWN buttons bit. */
#define KEMPSTON_JOYSTICK_BIT_DOWN  0x08
/** Kempston joystick FIRE buttons bit. */
#define KEMPSTON_JOYSTICK_BIT_FIRE  0x10



#endif //__JOYSTICK_H__
