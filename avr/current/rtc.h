#ifndef __RTC_H__
#define __RTC_H__

//address of PCF8583 RTC chip
#define RTC_ADDRESS  0xA0

void rtc_init(void);
void rtc_write(UBYTE addr, UBYTE data);
UBYTE rtc_read(UBYTE addr);

#endif //__RTC_H__
