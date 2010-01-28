#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/twi.h>
#include "pins.h"
#include "mytypes.h"

#include "rtc.h"
#include "rs232.h"

volatile UBYTE gluk_regs[16];

//stop transmit
#define tw_send_stop() {TWCR = (1<<TWINT)|(1<<TWEN)|(1<<TWSTO);}

static UBYTE tw_send_start(void)
{
	//start transmit
	TWCR = (1<<TWINT)|(1<<TWSTA)|(1<<TWEN);

	//wait for flag
	while (!(TWCR & (1<<TWINT)));

#ifdef LOGENABLE
	char log_reset_type[] = "TWS..\r\n";
	UBYTE b = TWSR;
	log_reset_type[3] = ((b >> 4) <= 9 )?'0'+(b >> 4):'A'+(b >> 4)-10;
	log_reset_type[4] = ((b & 0x0F) <= 9 )?'0'+(b & 0x0F):'A'+(b & 0x0F)-10;
	to_log(log_reset_type);
#endif
	//return status
   return TWSR&0xF8;
}

static UBYTE tw_send_addr(UBYTE addr)
{
	//set address
	TWDR = addr;

	//enable transmit
	TWCR = (1<<TWINT)|(1<<TWEN);

	//wait for end transmit
	while (!(TWCR & (1<<TWINT)));

#ifdef LOGENABLE
	char log_tw[] = "TWA.. ..\r\n";
	UBYTE b = TWSR;
	log_tw[3] = ((b >> 4) <= 9 )?'0'+(b >> 4):'A'+(b >> 4)-10;
	log_tw[4] = ((b & 0x0F) <= 9 )?'0'+(b & 0x0F):'A'+(b & 0x0F)-10;
	log_tw[6] = ((addr >> 4) <= 9 )?'0'+(addr >> 4):'A'+(addr >> 4)-10;
	log_tw[7] = ((addr & 0x0F) <= 9 )?'0'+(addr & 0x0F):'A'+(addr & 0x0F)-10;
	to_log(log_tw);
#endif
	//return status
   return TWSR&0xF8;
}

static UBYTE tw_send_data(UBYTE data)
{
	//set data
	TWDR = data;

	//enable transmit
	TWCR = (1<<TWINT)|(1<<TWEN);

	//wait for end transmit
	while (!(TWCR & (1<<TWINT)));

#ifdef LOGENABLE
	char log_tw[] = "TWD.. ..\r\n";
	UBYTE b = TWSR;
	log_tw[3] = ((b >> 4) <= 9 )?'0'+(b >> 4):'A'+(b >> 4)-10;
	log_tw[4] = ((b & 0x0F) <= 9 )?'0'+(b & 0x0F):'A'+(b & 0x0F)-10;
	log_tw[6] = ((data >> 4) <= 9 )?'0'+(data >> 4):'A'+(data >> 4)-10;
	log_tw[7] = ((data & 0x0F) <= 9 )?'0'+(data & 0x0F):'A'+(data & 0x0F)-10;
	to_log(log_tw);
#endif
	//return status
   return TWSR&0xF8;
}

static UBYTE tw_read_data(UBYTE* data)
{
	//enable
	TWCR = (1<<TWINT)|(1<<TWEN);

	//wait for flag set
	while (!(TWCR & (1<<TWINT)));

#ifdef LOGENABLE
	char log_tw[] = "TWR.. ..\r\n";
	UBYTE b = TWSR;
	log_tw[3] = ((b >> 4) <= 9 )?'0'+(b >> 4):'A'+(b >> 4)-10;
	log_tw[4] = ((b & 0x0F) <= 9 )?'0'+(b & 0x0F):'A'+(b & 0x0F)-10;
	log_tw[6] = ((TWDR >> 4) <= 9 )?'0'+(TWDR >> 4):'A'+(TWDR >> 4)-10;
	log_tw[7] = ((TWDR & 0x0F) <= 9 )?'0'+(TWDR & 0x0F):'A'+(TWDR & 0x0F)-10;
	to_log(log_tw);
#endif
	//get data
	*data = TWDR;

	//return status
   return TWSR & 0xF8;
}


void rtc_init(void)
{
	//SCL frequency = CPU clk/ ( 16 + 2* (TWBR) * 4^(TWPS) )
	// 11052000 / (16 + 2*48 ) = 98678,5Hz (100000Hz recommended for PCF8583)
	TWBR = 48;
	TWSR = 0;

	//reset RTC
	//write 0 to control/status register [0] on PCF8583
	rtc_write(0, 0);

	//test
//	rtc_read(4);
//	rtc_read(5);
//	rtc_read(6);
//	rtc_read(2);
//	rtc_read(3);
//	rtc_read(4);

	//set Gluk registers
	gluk_regs[GLUK_REG_B] = 0x06;
}

void rtc_write(UBYTE addr, UBYTE data)
{
	//set address
	if ( tw_send_start() & (TW_START|TW_REP_START) )
	{
		if ( tw_send_addr(RTC_ADDRESS) == TW_MT_SLA_ACK )
		{
			if ( tw_send_data(addr) == TW_MT_DATA_ACK )
			{
				//write data
				tw_send_data(data);
			}
		}
	}
	tw_send_stop();
}

UBYTE rtc_read(UBYTE addr)
{
	UBYTE ret = 0;
	//set address
	if ( tw_send_start() & (TW_START|TW_REP_START) )
	{
		if ( tw_send_addr(RTC_ADDRESS) == TW_MT_SLA_ACK )
		{
			if ( tw_send_data(addr) == TW_MT_DATA_ACK )
			{
				//read data
				if ( tw_send_start() == TW_REP_START )
				{
					if ( tw_send_addr(RTC_ADDRESS|0x01) == TW_MR_SLA_ACK )
					{
						tw_read_data(&ret);
					}
				}
			}
		}
	}
	tw_send_stop();
	return ret;
}

void gluk_inc(void)
{
	if ( ++gluk_regs[GLUK_REG_SEC] == 60 )
	{
		gluk_regs[GLUK_REG_SEC] = 0;
		if ( ++gluk_regs[GLUK_REG_MIN] == 60 )
		{
			gluk_regs[GLUK_REG_MIN] = 0;
			if ( ++gluk_regs[GLUK_REG_HOUR] == 24 )
			{
				gluk_regs[GLUK_REG_HOUR] = 0;
			}
		}
	}
//#ifdef LOGENABLE
//{
//	char log_int_rtc[] = "00.00.00\r\n";
//	log_int_rtc[0] = '0' + gluk_regs[GLUK_REG_HOUR]/10;
//	log_int_rtc[1] = '0' + gluk_regs[GLUK_REG_HOUR]%10;
//	log_int_rtc[3] = '0' + gluk_regs[GLUK_REG_MIN]/10;
//	log_int_rtc[4] = '0' + gluk_regs[GLUK_REG_MIN]%10;
//	log_int_rtc[6] = '0' + gluk_regs[GLUK_REG_SEC]/10;
//	log_int_rtc[7] = '0' + gluk_regs[GLUK_REG_SEC]%10;
//	to_log(log_int_rtc);
//}
//#endif
}

UBYTE get_gluk_reg(UBYTE index)
{
	if( index < sizeof(gluk_regs)/sizeof(gluk_regs[0]) )
	{
		//clock registers from array
		return gluk_regs[index];
	}
	else
	{
		//other registers from cmos
		return rtc_read(index&0x3F);
	}
}

void set_gluk_reg(UBYTE index, UBYTE data)
{
	if( index < sizeof(gluk_regs)/sizeof(gluk_regs[0]) )
	{
		//clock registers from array
		gluk_regs[index] = data;
	}
	else
	{
		//other registers to cmos
		rtc_write(index&0x3F, data);
	}
}
