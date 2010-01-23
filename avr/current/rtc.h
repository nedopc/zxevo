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

#endif //__RTC_H__
