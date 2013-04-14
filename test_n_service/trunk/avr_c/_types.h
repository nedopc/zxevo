#ifndef _TYPES_H
#define _TYPES_H

#include <inttypes.h>
#include <avr/pgmspace.h>
#include <avr/eeprom.h>

#define u8   uint8_t
#define u16 uint16_t
#define u32 uint32_t
//#define s8    int8_t
//#define s16  int16_t
//#define s32  int32_t

#define PGMSTR(s) (__extension__({static uint8_t __c[] PROGMEM = (s); &__c[0];}))
#define PGM_U8_P const prog_uint8_t *

#endif

