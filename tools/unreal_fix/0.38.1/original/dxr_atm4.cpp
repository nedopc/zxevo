#include "std.h"

#include "emul.h"
#include "vars.h"
#include "draw.h"
#include "dxr_atmf.h"
#include "dxr_atm4.h"
#include "fontatm2.h"

// vga like textmode (80x25)

static const int text0_ofs = 4*PAGE + 0x0;
static const int text2_ofs = 4*PAGE + 0x800;

void line_atm4_8(unsigned char *dst, unsigned char *src, unsigned *tab0, unsigned char *font)
{
    for (unsigned x = 0; x < 640; x += 0x20)
    {
        unsigned p0 = *(unsigned*)(src + text0_ofs),
                 a0 = *(unsigned*)(src + text2_ofs);
        unsigned c, *tab;
        tab = tab0 + ((a0 << 4) & 0xFF0), c = font[p0 & 0xFF];
        *(unsigned*)(dst+x+0x00) = tab[((c >> 4)  & 0xF)];
        *(unsigned*)(dst+x+0x04) = tab[c & 0xF];

        tab = tab0 + ((a0 >> 4) & 0xFF0); c = font[(p0 >> 8) & 0xFF];
        *(unsigned*)(dst+x+0x08) = tab[((c >> 4) & 0xF)];
        *(unsigned*)(dst+x+0x0C) = tab[c & 0xF];

        tab = tab0 + ((a0 >> 12) & 0xFF0); c = font[(p0 >> 16) & 0xFF];
        *(unsigned*)(dst+x+0x10) = tab[((c >> 4) & 0xF)];
        *(unsigned*)(dst+x+0x14) = tab[c & 0xF];

        tab = tab0 + ((a0 >> 20) & 0xFF0); c = font[p0 >> 24];
        *(unsigned*)(dst+x+0x18) = tab[((c >> 4) & 0xF)];
        *(unsigned*)(dst+x+0x1C) = tab[c & 0xF];

        src += 4;
    }
}

void line_atm4_16(unsigned char *dst, unsigned char *src, unsigned *tab0, unsigned char *font)
{
    for (unsigned x = 0; x < 640*2; x += 0x40)
    {
        unsigned p0 = *(unsigned*)(src + text0_ofs),
                 a0 = *(unsigned*)(src + text2_ofs);
        unsigned c, *tab;
        tab = tab0 + ((a0 << 2) & 0x3FC), c = font[p0 & 0xFF];
        *(unsigned*)(dst+x+0x00) = tab[((c >> 6)  & 0x03)];
        *(unsigned*)(dst+x+0x04) = tab[((c >> 4)  & 0x03)];
        *(unsigned*)(dst+x+0x08) = tab[((c >> 2)  & 0x03)];
        *(unsigned*)(dst+x+0x0C) = tab[((c >> 0)  & 0x03)];

        tab = tab0 + ((a0 >> 6) & 0x3FC); c = font[(p0 >> 8) & 0xFF];
        *(unsigned*)(dst+x+0x10) = tab[((c >> 6)  & 0x03)];
        *(unsigned*)(dst+x+0x14) = tab[((c >> 4)  & 0x03)];
        *(unsigned*)(dst+x+0x18) = tab[((c >> 2)  & 0x03)];
        *(unsigned*)(dst+x+0x1C) = tab[((c >> 0)  & 0x03)];
        
        tab = tab0 + ((a0 >> 14) & 0x3FC); c = font[(p0 >> 16) & 0xFF];
        *(unsigned*)(dst+x+0x20) = tab[((c >> 6)  & 0x03)];
        *(unsigned*)(dst+x+0x24) = tab[((c >> 4)  & 0x03)];
        *(unsigned*)(dst+x+0x28) = tab[((c >> 2)  & 0x03)];
        *(unsigned*)(dst+x+0x2C) = tab[((c >> 0)  & 0x03)];

        tab = tab0 + ((a0 >> 22) & 0x3FC); c = font[p0 >> 24];
        *(unsigned*)(dst+x+0x30) = tab[((c >> 6)  & 0x03)];
        *(unsigned*)(dst+x+0x34) = tab[((c >> 4)  & 0x03)];
        *(unsigned*)(dst+x+0x38) = tab[((c >> 2)  & 0x03)];
        *(unsigned*)(dst+x+0x3C) = tab[((c >> 0)  & 0x03)];

        src += 4;
    }
}

void line_atm4_32(unsigned char *dst, unsigned char *src, unsigned *tab0, unsigned char *font)
{
   for (unsigned x = 0; x < 640*4; x += 0x40)
   {
      unsigned c, *tab;
      tab = tab0 + src[text2_ofs]; c = font[src[text0_ofs]];
      *(unsigned*)(dst+x+0x00) = tab[((c << 1) & 0x100)];
      *(unsigned*)(dst+x+0x04) = tab[((c << 2) & 0x100)];
      *(unsigned*)(dst+x+0x08) = tab[((c << 3) & 0x100)];
      *(unsigned*)(dst+x+0x0C) = tab[((c << 4) & 0x100)];
      *(unsigned*)(dst+x+0x10) = tab[((c << 5) & 0x100)];
      *(unsigned*)(dst+x+0x14) = tab[((c << 6) & 0x100)];
      *(unsigned*)(dst+x+0x18) = tab[((c << 7) & 0x100)];
      *(unsigned*)(dst+x+0x1C) = tab[((c << 8) & 0x100)];

      tab = tab0 + src[text2_ofs + 1]; c = font[src[text0_ofs + 1]];
      *(unsigned*)(dst+x+0x20) = tab[((c << 1) & 0x100)];
      *(unsigned*)(dst+x+0x24) = tab[((c << 2) & 0x100)];
      *(unsigned*)(dst+x+0x28) = tab[((c << 3) & 0x100)];
      *(unsigned*)(dst+x+0x2C) = tab[((c << 4) & 0x100)];
      *(unsigned*)(dst+x+0x30) = tab[((c << 5) & 0x100)];
      *(unsigned*)(dst+x+0x34) = tab[((c << 6) & 0x100)];
      *(unsigned*)(dst+x+0x38) = tab[((c << 7) & 0x100)];
      *(unsigned*)(dst+x+0x3C) = tab[((c << 8) & 0x100)];

      src += 2;
   }
}

// Textmode
void rend_atm4(unsigned char *dst, unsigned pitch, int y)
{
   unsigned char *dst2 = dst + (temp.ox-640)*temp.obpp/16;
   if (temp.scy > 200) 
       dst2 += (temp.scy-200)/2*pitch * ((temp.oy > temp.scy)?2:1);

    int v = y%8;
    int l = y/8;
    if (conf.fast_sl)
    {
        dst2 += y*pitch;
        switch(temp.obpp)
        {
        case 8:
            line_atm4_8 (dst2, temp.base + l*80, t.zctab8 [0], fontatm2 + v*0x100); 
            break;
        case 16:
            line_atm4_16(dst2, temp.base + l*80, t.zctab16[0], fontatm2 + v*0x100); 
            break;
        case 32:
            line_atm4_32(dst2, temp.base + l*80, t.zctab32[0], fontatm2 + v*0x100); 
            break;
        }
    }
    else
    {
        dst2 += 2*y*pitch;
        switch(temp.obpp)
        {
        case 8:
            line_atm4_8 (dst2, temp.base + l*80, t.zctab8 [0], fontatm2 + v*0x100); 
            dst2 += pitch;
            line_atm4_8 (dst2, temp.base + l*80, t.zctab8 [1], fontatm2 + v*0x100);
            break;
        case 16:
            line_atm4_16(dst2, temp.base + l*80, t.zctab16[0], fontatm2 + v*0x100); 
            dst2 += pitch;
            line_atm4_16(dst2, temp.base + l*80, t.zctab16[1], fontatm2 + v*0x100);
            break;
        case 32:
            line_atm4_32(dst2, temp.base + l*80, t.zctab32[0], fontatm2 + v*0x100); 
            dst2 += pitch;
            line_atm4_32(dst2, temp.base + l*80, t.zctab32[1], fontatm2 + v*0x100);
            break;
        }
    }
}
