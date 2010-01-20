#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>

#include <util/delay.h>


#include "mytypes.h"
#include "depacker_dirty.h"
#include "getfaraddress.h"
#include "pins.h"

#include "ps2.h"
#include "zx.h"
#include "spi.h"
#include "rs232.h"
#include "rtc.h"


//fpga compressed data
extern const char fpga[] PROGMEM; // linker symbol

ULONG indata;
UBYTE dbuf[DBSIZE];

void InitHardware(void);

int main()
{
	UBYTE j;


	InitHardware();

#ifdef LOGENABLE
	rs232_init();
#endif


	PORTF |= (1<<PF3); // turn POWER on

	j=50;
	do _delay_ms(20); while(--j); //1 sec delay


	//begin configuring, led ON
	PORTB &= ~(1<<LED);


	spi_init();



	DDRF |= (1<<nCONFIG); // pull low for a time
	_delay_us(40);
	DDRF &= ~(1<<nCONFIG);
	while( !(PINF & (1<<nSTATUS)) ); // wait ready
	indata = (ULONG)GET_FAR_ADDRESS(fpga); // prepare for data fetching
	depacker_dirty();


	//LED off
	PORTB |= (1<<LED);



	// start timer (led dimming and timeouts for ps/2)
	TCCR2 = 0b01110011; // FOC2=0, {WGM21,WGM20}=01, {COM21,COM20}=11, {CS22,CS21,CS20}=011
	                    // clk/64 clocking,
	                    // 1/512 overflow rate, total 11.059/32768 = 337.5 Hz interrupt rate
	TIFR = (1<<TOV2);
	TIMSK = (1<<TOIE2);


	//init some device
    ps2keyboard_count = 11;
	ps2mouse_count = 12;
	ps2mouse_initstep = 0;
	ps2mouse_resp_count = 0;
	ps2_flags = 0;

	zx_mouse_reset();

	//set external interrupt
	//INT4 - PS2 Keyboard  (falling edge)
	//INT5 - PS2 Mouse     (falling edge)
	EICRB = (1<<ISC41)+(0<<ISC40) + (1<<ISC51)+(0<<ISC50); // set condition for interrupt
	EIFR = (1<<INTF4)|(1<<INTF5); // clear spurious ints there
	EIMSK |= (1<<INT4)|(1<<INT5); // enable

	rtc_init();
	zx_init();

#ifdef LOGENABLE
	to_log("zx_init OK\r\n");
#endif


	sei(); // globally go interrupting

	//main loop
    for(;;)
    {
        ps2keyboard_task();
		ps2mouse_task();
        zx_task(ZX_TASK_WORK);
		zx_mouse_task();
    }

}

void InitHardware(void)
{

	cli(); // disable interrupts



	// configure pins

	PORTG = 0b11111111;
	DDRG  = 0b00000000;

	PORTF = 0b11110000; // ATX off (zero output), fpga config/etc inputs
	DDRF  = 0b00001000;

	PORTE = 0b11111111;
	DDRE  = 0b00000000; // inputs pulled up

	PORTD = 0b11111111;
	DDRD  = 0b00000000; // same

	PORTC = 0b11011111;
	DDRC  = 0b00000000; // PWRGOOD input, other pulled up

	PORTB = 0b11110001;
	DDRB  = 0b10000111; // LED off, spi outs inactive

	PORTA = 0b11111111;
	DDRA  = 0b00000000; // pulled up


	ACSR = 0x80; // DISABLE analog comparator
}


void put_buffer(UWORD size)
{ // writes specified length of buffer to the output
	UBYTE * ptr;
	ptr=dbuf;

	do
	{
		spi_send( *(ptr++) );

	} while(--size);
}

