#ifndef PINS_H
#define PINS_H

/**
 * Used pins definition:
 * define PIN
 * define PORT
 * define input PINs
 * define Data Direction Register
 */

#define nCONFIG      PF0
#define nCONFIG_PORT PORTF
#define nCONFIG_PIN  PINF
#define nCONFIG_DDR  DDRF

#define nSTATUS      PF1
#define nSTATUS_PORT PORTF
#define nSTATUS_PIN  PINF
#define nSTATUS_DDR  DDRF

#define CONF_DONE PF2
#define CONF_DONE_PORT PORTF
#define CONF_DONE_PIN  PINF
#define CONF_DONE_DDR  DDRF

/** LED */
#define LED      PB7
#define LED_PORT PORTB
#define LED_PIN  PINB
#define LED_DDR  DDRB

/** PS2 keyboard clock */
#define PS2KBCLK PE4
#define PS2KBCLK_PORT PORTE
#define PS2KBCLK_PIN  PINE
#define PS2KBCLK_DDR  DDRE

/** PS2 keyboard data */
#define PS2KBDAT PD6
#define PS2KBDAT_PORT PORTD
#define PS2KBDAT_PIN  PIND
#define PS2KBDAT_DDR  DDRD

/** PS2 mouse clock */
#define PS2MSCLK PE5
#define PS2MSCLK_PORT PORTE
#define PS2MSCLK_PIN  PINE
#define PS2MSCLK_DDR  DDRE

/** PS2 mouse data */
#define PS2MSDAT PD7
#define PS2MSDAT_PORT PORTD
#define PS2MSDAT_PIN  PIND
#define PS2MSDAT_DDR  DDRD

/** RS232 TXD */
#define RS232TXD PD3
#define RS232TXD_PORT PORTD
#define RS232TXD_PIN  PIND
#define RS232TXD_DDR  DDRD

#define nSPICS      PB0
#define nSPICS_PORT PORTB
#define nSPICS_PIN  PINB
#define nSPICS_DDR  DDRB

/** ATX POWER ON */
#define ATXPWRON      PF3
#define ATXPWRON_PORT PORTF
#define ATXPWRON_PIN  PINF
#define ATXPWRON_DDR  DDRF

/** SOFT RESET */
#define SOFTRES      PC7
#define SOFTRES_PORT PORTC
#define SOFTRES_PIN  PINC
#define SOFTRES_DDR  DDRC

/** JOYSTICK */
#define JOYSTICK_RIGHT PG0
#define JOYSTICK_LEFT  PG1
#define JOYSTICK_DOWN  PG2
#define JOYSTICK_UP    PG3
#define JOYSTICK_FIRE  PG4
#define JOYSTICK_MASK  ((1<<JOYSTICK_RIGHT)|(1<<JOYSTICK_LEFT)|(1<<JOYSTICK_UP)|(1<<JOYSTICK_DOWN)|(1<<JOYSTICK_FIRE))
#define JOYSTICK_PORT  PORTG
#define JOYSTICK_PIN   PING
#define JOYSTICK_DDR   DDRC

#endif

