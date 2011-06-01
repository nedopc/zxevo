#include <stdio.h>
#include <stdlib.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#include "sndpix.h"

DPI_LINK_DECL DPI_DLLESPEC
int
sndpix(
    int hcoord,
    int vcoord,
    int rrggbb,
    int hperiod,
    int vperiod)
{

	static int need_init = 1;
	static int sock_error=0;
	static int mysocket;
	struct sockaddr_in addr;
	char buf[256];





	if( need_init )
	{
		need_init = 0;


		mysocket = socket(AF_INET, SOCK_STREAM, 0);

		if(mysocket<0) sock_error++;


		addr.sin_family = AF_INET;
		addr.sin_port = htons(12345);
//		addr.sin_addr.s_addr = htonl(0xAC100594); //172.16.5.148
		addr.sin_addr.s_addr = htonl(0x7F000001); //127.0.0.1



		if( !sock_error)
		{
			if( connect(mysocket, (struct sockaddr *)&addr, sizeof(addr) ) )
			{
				sock_error++;
			}
		}
	}



	if( !sock_error )
	{
//		sprintf(buf,"%08X<=%08X:%08X with %02X\n",adr,dat_hi,dat_lo,sel);

		sprintf(buf,"%04X,%04X,%04X,%04X,%02X\n",hperiod,vperiod,hcoord,vcoord,rrggbb);

		if( strlen(buf)!=send(mysocket, buf, strlen(buf), 0) )
			sock_error++;
	}
	else
	{
		sock_error = 0;
		need_init = 1;

		if( mysocket>=0 )
			close(mysocket);
	}


	return 0;
}

