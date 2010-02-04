#include <avr/io.h>

#include "pins.h"
#include "mytypes.h"

#include "rs232.h"
#include "joystick.h"

void joystick_task(void)
{
	static UBYTE joy_state = 0;
	UBYTE temp = JOYSTICK_PIN;

	if ( (joy_state ^ temp) & JOYSTICK_MASK )
	{
		//change state of joystick pins
		joy_state = temp & JOYSTICK_MASK;

	   //calculate content of kempston joysticks port
	   temp = ((joy_state & (1<<JOYSTICK_RIGHT))? 0: KEMPSTON_JOYSTICK_BIT_RIGHT ) +
			  ((joy_state & (1<<JOYSTICK_LEFT))? 0: KEMPSTON_JOYSTICK_BIT_LEFT ) +
			  ((joy_state & (1<<JOYSTICK_UP))? 0: KEMPSTON_JOYSTICK_BIT_UP ) +
			  ((joy_state & (1<<JOYSTICK_DOWN))? 0: KEMPSTON_JOYSTICK_BIT_DOWN )+
			  ((joy_state & (1<<JOYSTICK_FIRE))? 0: KEMPSTON_JOYSTICK_BIT_FIRE );

#ifdef LOGENABLE
	char log_joystick[] = "JS..\r\n";
	log_joystick[2] = ((temp >> 4) <= 9 )?'0'+(temp >> 4):'A'+(temp >> 4)-10;
	log_joystick[3] = ((temp & 0x0F) <= 9 )?'0'+(temp & 0x0F):'A'+(temp & 0x0F)-10;
	to_log(log_joystick);
#endif

		//send to port
		//zx_spi_send(addr, temp, 0x7F);
	}
}
