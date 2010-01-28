#ifndef __RTC_H__
#define __RTC_H__

/** Address of PCF8583 RTC chip.*/
#define RTC_ADDRESS  0xA0

/** Init RTC.*/
void rtc_init(void);

/**
 * Write byte to RTC.
 * @par addr [in] - address of internal register on RTC
 * @par data [in] - data to write
 */
void rtc_write(UBYTE addr, UBYTE data);

/**
 * Read byte from RTC.
 * @return data
 * @par addr [in] - address of internal register on RTC
 */
UBYTE rtc_read(UBYTE addr);


/**
 * Constants for Gluk clock scheme emulation.
 */

/** Seconds register index. */
#define GLUK_REG_SEC        0x00
/** Seconds alarm register index. */
#define GLUK_REG_SEC_ALARM  0x01
/** Minutes register index. */
#define GLUK_REG_MIN        0x02
/** Minutes alarm register index. */
#define GLUK_REG_MIN_ALARM  0x03
/** Hours register index. */
#define GLUK_REG_HOUR       0x04
/** Hours alarm register index. */
#define GLUK_REG_HOUR_ALARM 0x05
/** Day of week register index. */
#define GLUK_REG_DAY_WEEK   0x06
/** Day of month register index. */
#define GLUK_REG_DAY_MONTH  0x07
/** Month register index. */
#define GLUK_REG_MONTH      0x08
/** Year register index. */
#define GLUK_REG_YEAR       0x09
/** A register index. */
#define GLUK_REG_A          0x0A
/** B register index. */
#define GLUK_REG_B          0x0B
/** C register index. */
#define GLUK_REG_C          0x0C
/** D register index. */
#define GLUK_REG_D          0x0D

/** Increment Gluk clock registers on one second */
void gluk_inc(void);

/**
 * Get Gluk clock registers data.
 * @return registers data
 * @par index [in] - index of Gluck clock register
 */
UBYTE get_gluk_reg(UBYTE index);

void set_gluk_reg(UBYTE index, UBYTE data);



#endif //__RTC_H__
