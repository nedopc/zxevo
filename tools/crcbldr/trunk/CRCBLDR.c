#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef unsigned char BYTE;
typedef unsigned short int WORD;
typedef unsigned int LONGWORD;

#define HEXLEN 0
#define DATATYPE 1
#define CHECKSUM 2

BYTE      checksum;
WORD      col, row;
LONGWORD  err;
BYTE      s[256], s1[256];

//-----------------------------------------------------------------------------

BYTE toupper(BYTE b)
{
 if ( (b>0x61) && (b<0x7b) )  b&=0xdf;
 return b;
}

//-----------------------------------------------------------------------------

void print_err_rc()
{
 printf("Error! (Row %d, Col %d)\n",row,col+1);
 err++;
}

//-----------------------------------------------------------------------------

void print_err_r(BYTE cause)
{
 BYTE* cause_str[3]={"Number of byte","Unknown datatype","Checksum"};
 printf("Error! %s. (Row %d)\n",cause_str[cause],row);
 err++;
}

//-----------------------------------------------------------------------------

BYTE getbyte()
{
 BYTE  b1, b0;

 b1=s[col];
 if ( ( (b1>=0x30)&&(b1<=0x39) )||( (b1>=0x41)&&(b1<=0x46) ) )
 {
  b1-=0x30;
  if (b1>9) b1-=7;
 }
 else
 {
  print_err_rc();
  b1=0;
 }
 col++;

 b0=s[col];
 if ( ( (b0>=0x30)&&(b0<=0x39) )||( (b0>=0x41)&&(b0<=0x46) ) )
 {
  b0-=0x30;
  if (b0>9) b0-=7;
 }
 else
 {
  print_err_rc();
  b0=0;
 }
 col++;

 b0|=(b1<<4);
 checksum+=b0;
 return b0;
}

//-----------------------------------------------------------------------------

int main(int argc,char*argv[])
{
 BYTE       h[]="0123456789ABCDEF";
 BYTE       b, m, hexlen, datatype;
 WORD       i, crc;
 LONGWORD   x0, x1, adr, segadr;
 WORD       tabcrc[256];
 BYTE       buff[0x2000];
 FILE*      f;

 printf("ZX EVO project:  Calc CRC for bootloader\n");
 if (argc!=2) { printf("usage: CRCBLDR <HexFileName>\n"); return 2; }
 strncpy(s1,argv[1],255);
 f=fopen(s1,"rt");
 if (!f) { printf("Can't open file %s!\n",s1); return 1; }

 for (adr=0;adr<0x2000;adr++) buff[adr]=0xff;
 err=0;
 segadr=0;
 row=0;
 while (!feof(f))
 {
  row++;
  col=0;
  if (fgets(s,255,f) && strlen(s))
  {
   if (s[col]!=':') print_err_rc();
   col++;
   checksum=0;
   hexlen=getbyte();
   x1=getbyte();
   x0=getbyte();
   adr=segadr|(x1<<8)|x0;
   datatype=getbyte();
   switch (datatype)
   {
    // Data record
    case 0: while (hexlen>0)
            {
             b=getbyte();
             hexlen--;
             if ( (adr>=0x1e000) && (adr<0x20000) ) buff[adr-0x1e000]=b;
             adr++;
            }
            break;
    // End of file record
    case 1: if (hexlen!=0) print_err_r(HEXLEN);
            break;
    // Extended segment address record
    case 2: x1=getbyte();
            x0=getbyte();
            segadr=(x1<<12)|(x0<<4);
            if (hexlen!=2) print_err_r(HEXLEN);
            break;
    // Start segment address record
    case 3: break;
    // Extended linear address record
    case 4: x1=getbyte();
            x0=getbyte();
            segadr=(x1<<24)|(x0<<16);
            if (hexlen!=2) print_err_r(HEXLEN);
            break;
    // Start linear address record
    case 5: break;
    default: print_err_r(DATATYPE);
             while (hexlen!=0) { getbyte(); hexlen--; }
   }
   getbyte();
   if (checksum!=0) print_err_r(CHECKSUM);
  }
 }
 fclose(f);

 if (err) { printf("Total %d error(s)!\n",err); return 3; }

 for (i=0;i<256;i++)
 {
  crc=i<<8;
  b=8;
  do
  {
   if (crc&0x8000)
    crc=(crc<<1)^0x1021;
   else
    crc<<=1;
   b--;
  }
  while ((b)&&(crc));
  tabcrc[i]=crc;
 }

 crc=0xffff;
 for (adr=0;adr<0x1ffe;adr++) crc=tabcrc[(crc>>8)^buff[adr]]^(crc<<8);
 buff[0x1ffe]=crc>>8;
 buff[0x1fff]=crc&0xff;

 f=fopen("ZXEVO_BL.HEX","wt");
 if (!f) { printf("Can't create output file!\n"); return 1; }

 fputs(":020000020000FC\n:01000000FF00\n:020000021000EC\n",f);
 s[0]=':';
 s[1]='1';
 s[2]='0';
 adr=0;

 do
 {
  checksum=0xf0;
  m=3;
  b=((adr>>8)&0xff)+0xe0;
  checksum-=b;
  s[m++]=h[b>>4];
  s[m++]=h[b&0x0f];
  b=adr&0xff;
  checksum-=b;
  s[m++]=h[b>>4];
  s[m++]=h[b&0x0f];
  s[m++]='0';
  s[m++]='0';
  for (i=0;i<16;i++)
  {
   b=buff[adr++];
   checksum-=b;
   s[m++]=h[b>>4];
   s[m++]=h[b&0x0f];
  }
  s[m++]=h[checksum>>4];
  s[m++]=h[checksum&0x0f];
  s[m++]='\n';
  s[m]=0;
  fputs(s,f);
 }
 while (adr<0x2000);

 fputs(":00000001FF\n",f);
 fclose(f);

 printf("Created file ZXEVO_BL.HEX");
 return 0;
}
