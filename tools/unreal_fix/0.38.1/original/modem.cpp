#include "std.h"

#include "emul.h"
#include "vars.h"

#include "util.h"

void ISA_MODEM::open(int port)
{
   if (open_port == port)
       return;
   whead = wtail = rhead = rtail = 0;
   if (hPort && hPort != INVALID_HANDLE_VALUE)
   {
       CloseHandle(hPort);
       CloseHandle(OvW.hEvent);
       CloseHandle(OvR.hEvent);
   }
   open_port = port;
   if (!port)
       return;

   char portName[11];
   _snprintf(portName, _countof(portName), "\\\\.\\COM%d", port);

   hPort = CreateFile(portName, GENERIC_READ | GENERIC_WRITE, 0, 0, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);
   if (hPort == INVALID_HANDLE_VALUE)
   {
      errmsg("can't open modem on %s", portName); err_win32();
      conf.modem_port = open_port = 0;
      return;
   }

   memset(&OvW, 0, sizeof(OvW));
   memset(&OvR, 0, sizeof(OvR));

   OvW.hEvent = CreateEvent(0, TRUE, TRUE, 0);
   OvR.hEvent = CreateEvent(0, TRUE, TRUE, 0);

   COMMTIMEOUTS times;
   times.ReadIntervalTimeout = MAXDWORD;
   times.ReadTotalTimeoutMultiplier = 0;
   times.ReadTotalTimeoutConstant = 0;
   times.WriteTotalTimeoutMultiplier = 0;
   times.WriteTotalTimeoutConstant = 0;
   SetCommTimeouts(hPort, &times);

#if 0
   DCB dcb;
   if (GetCommState(hPort, &dcb)) {
      printf(
       "modem state:\n"
       "rate=%d\n"
       "parity=%d, OutxCtsFlow=%d, OutxDsrFlow=%d, DtrControl=%d, DsrSensitivity=%d\n"
       "TXContinueOnXoff=%d, OutX=%d, InX=%d, ErrorChar=%d\n"
       "Null=%d, RtsControl=%d, AbortOnError=%d, XonLim=%d, XoffLim=%d\n"
       "ByteSize=%d, Parity=%d, StopBits=%d\n"
       "XonChar=#%02X, XoffChar=#%02X, ErrorChar=#%02X, EofChar=#%02X, EvtChar=#%02X\n\n",
       dcb.BaudRate,
       dcb.fParity, dcb.fOutxCtsFlow, dcb.fOutxDsrFlow, dcb.fDtrControl, dcb.fDsrSensitivity,
       dcb.fTXContinueOnXoff, dcb.fOutX, dcb.fInX, dcb.fErrorChar,
       dcb.fNull, dcb.fRtsControl, dcb.fAbortOnError, dcb.XonLim, dcb.XoffLim,
       dcb.ByteSize, dcb.Parity, dcb.StopBits,
       (BYTE)dcb.XonChar, (BYTE)dcb.XoffChar, (BYTE)dcb.ErrorChar, (BYTE)dcb.EofChar, (BYTE)dcb.EvtChar);
   }
#endif
}

void ISA_MODEM::close()
{
   if (!hPort || hPort == INVALID_HANDLE_VALUE)
       return;
   CloseHandle(hPort);
   hPort = INVALID_HANDLE_VALUE;
   open_port = 0;
   CloseHandle(OvW.hEvent);
   CloseHandle(OvR.hEvent);
}

void ISA_MODEM::io()
{
   if (!hPort || hPort == INVALID_HANDLE_VALUE)
       return;

   static u8 tempwr[BSIZE];
   static u8 temprd[BSIZE];

   DWORD written = 0;
   bool WrReady = false;
   if(WaitForSingleObject(OvW.hEvent, 0) == WAIT_OBJECT_0)
   {
       written = OvW.InternalHigh;
       OvW.InternalHigh = 0;
       wtail = (wtail+written) & (BSIZE-1);
/*
       if(written)
       {
           printf("write complete: %d\n", written);
       }
*/
       WrReady = true;
   }

   int needwrite = whead - wtail;
   if (needwrite < 0)
       needwrite += BSIZE;
   if (needwrite && WrReady)
   {
      if (whead > wtail)
          memcpy(tempwr, wbuf+wtail, needwrite);
      else
      {
          memcpy(tempwr, wbuf+wtail, BSIZE-wtail);
          memcpy(tempwr+BSIZE-wtail, wbuf, whead);
      }

      if (WriteFile(hPort, tempwr, needwrite, &written, &OvW))
      {
      // printf("\nsend: "); dump1(temp, written);
      // printf("writen : %d, %d\n", needwrite, written);
      }
      else
      {
      // printf("write pending : %d, %d\n", needwrite, written);
      }
   }
   if (((whead+1) & (BSIZE-1)) != wtail)
       reg[5] |= 0x60;

   bool RdReady = false;
   DWORD read = 0;
   if(WaitForSingleObject(OvR.hEvent, 0) == WAIT_OBJECT_0)
   {
       read = OvR.InternalHigh;
       OvR.InternalHigh = 0;
       if(read)
       {
          for (unsigned i = 0; i < read; i++)
          {
              rcbuf[rhead++] = temprd[i];
              rhead &= (BSIZE-1);
          }
       }
 
       RdReady = true;
   }

   int canread = rtail - rhead - 1;
   if (canread < 0)
       canread += BSIZE;
   if (canread && RdReady)
   {
      if (ReadFile(hPort, temprd, canread, &read, &OvR) && read)
      {
//printf("\nrecv: "); dump1(temp, read);
      }
   }
   if (rhead != rtail)
       reg[5] |= 1;

   setup_int();
}

void ISA_MODEM::setup_int()
{
   reg[6] &= ~0x10;

   unsigned char mask = reg[5] & 1;
   if (reg[5] & 0x20) mask |= 2, reg[6] |= 0x10;
   if (reg[5] & 0x1E) mask |= 4;
   // if (mask & reg[1]) cpu.nmi()

   if (mask & 4) reg[2] = 6;
   else if (mask & 1) reg[2] = 4;
   else if (mask & 2) reg[2] = 2;
   else if (mask & 8) reg[2] = 0;
   else reg[2] = 1;
}

void ISA_MODEM::write(unsigned nreg, unsigned char value)
{
   DCB dcb;

   if ((1<<nreg) & ((1<<2)|(1<<5)|(1<<6)))
       return; // R/O registers

   if (nreg < 2 && (reg[3] & 0x80))
   {
     div[nreg] = value;
     if (GetCommState(hPort, &dcb))
     {
       if (!divfq)
           divfq = 1;
       dcb.BaudRate = 115200 / divfq;
       SetCommState(hPort, &dcb);
     }
     return;
   }

   if (nreg == 0)
   { // THR, write char to output buffer
      reg[5] &= ~0x60;
      if (((whead+1) & (BSIZE-1)) == wtail)
      {
/*
         printf("write to ful FIFO\n");
         reg[5] |= 2; // Overrun error  (Ошибка, этот бит только на прием, а не на передачу)
*/
      }
      else
      {
         wbuf[whead++] = value;
         whead &= (BSIZE-1);
         if (((whead+1) & (BSIZE-1)) != wtail)
             reg[5] |= 0x60; // Transmitter holding register empty | transmitter empty
      }
      setup_int();
      return;
   }

   u8 old = reg[nreg];
   reg[nreg] = value;

   if(nreg == 2) // FCR
   {
       ULONG Flags = 0;
       if(value & 2) // RX FIFO reset
           Flags |= PURGE_RXCLEAR | PURGE_RXABORT;

       if(value & 4) // TX FIFO reset
           Flags |= PURGE_TXCLEAR | PURGE_TXABORT;

       if(Flags)
           PurgeComm(hPort, Flags);
   }

   // Thu 28 Jul 2005. transfer mode control (code by Alex/AT)

   if (nreg == 3)
   {
      // LCR set, renew modem config
      if (!GetCommState(hPort, &dcb))
          return;

      dcb.fBinary = TRUE;
      dcb.fParity = (reg[3] & 8)? TRUE : FALSE;
      dcb.fOutxCtsFlow = FALSE;
      dcb.fOutxDsrFlow = FALSE;
      dcb.fDtrControl = DTR_CONTROL_DISABLE;
      dcb.fDsrSensitivity = FALSE;
      dcb.fTXContinueOnXoff = FALSE;
      dcb.fOutX = FALSE;
      dcb.fInX = FALSE;
      dcb.fErrorChar = FALSE;
      dcb.fNull = FALSE;
      dcb.fRtsControl = RTS_CONTROL_DISABLE;
      dcb.fAbortOnError = FALSE;
      dcb.ByteSize = 5 + (reg[3] & 3); // fix by Deathsoft

      static const BYTE parity[] = { ODDPARITY, EVENPARITY, MARKPARITY, SPACEPARITY };
      dcb.Parity = (reg[3] & 8) ? parity[(reg[3]>>4) & 3] : NOPARITY;

      if (!(reg[3] & 4)) dcb.StopBits = ONESTOPBIT;
      else dcb.StopBits = ((reg[3] & 3) == 1) ? ONE5STOPBITS : TWOSTOPBITS;

      SetCommState(hPort, &dcb);
      return;
   }

   if (nreg == 4)
   {
      // MCR set, renew DTR/RTS
      if((old ^ reg[4]) & 0x20) // auto rts/cts toggled
      {
          if (!GetCommState(hPort, &dcb))
              return;

          if(reg[4] & 0x20) // auto rts/cts enabled
          {
              dcb.fOutxCtsFlow = TRUE;
              dcb.fRtsControl = RTS_CONTROL_HANDSHAKE;
          }
          else // auto rts/cts disabled
          {
              dcb.fOutxCtsFlow = FALSE;
              dcb.fRtsControl = RTS_CONTROL_DISABLE;
          }
          SetCommState(hPort, &dcb);
      }

      if(!(reg[4] & 0x20)) // auto rts/cts disabled
      {
          if((old ^ reg[4]) & 1)
          {
              EscapeCommFunction(hPort, (reg[4] & 1) ? SETDTR : CLRDTR);
          }

          if((old ^ reg[4]) & 2)
          {
              EscapeCommFunction(hPort, (reg[4] & 2) ? SETRTS : CLRRTS);
          }
      }
   }
}

unsigned char ISA_MODEM::read(unsigned nreg)
{
   if (nreg < 2 && (reg[3] & 0x80))
       return div[nreg];

   unsigned char result = reg[nreg];

   if (nreg == 0)
   { // read char from buffer
      if (rhead != rtail)
      {
           result = reg[0] = rcbuf[rtail++];
           rtail &= (BSIZE-1);
      }

      if (rhead != rtail)
          reg[5] |= 1;
      else
          reg[5] &= ~1;

      setup_int();
   }

   if (nreg == 5)
   {
       reg[5] &= ~0x0E;
       setup_int();
   }

   if (nreg == 6)
   {
       DWORD ModemStatus;
       GetCommModemStatus(hPort, &ModemStatus);
       u8 r6 = reg[6];
       reg[6] &= ~(1 << 4);
       reg[6] |= (ModemStatus & MS_CTS_ON) ? (1 << 4): 0;
       reg[6] &= ~1;
       reg[6] |= ((r6 ^ reg[6]) & (1 << 4)) >> 4;
       result = reg[6];
   }
   return result;
}
