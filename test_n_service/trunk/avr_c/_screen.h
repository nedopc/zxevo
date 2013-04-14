#ifndef _SCREEN_H
#define _SCREEN_H

#include "_types.h"

typedef struct {
 const u8 x;                    // коорд.лев.верхн угола окна
 const u8 y;                    //
 const u8 width;                // ширина (без учёта тени)
 const u8 height;               // высота (без учёта тени)
 const u8 attr;                 // атрибут окна
 const u8 flag;                 // флаги: .0 - "с тенью/без тени"
} WIND_DESC;

typedef struct {
 const u8 x;                    // коорд.лев.верхн угола окна
 const u8 y;                    //
 const u8 width;                // длина_строки + 2 = ширина без учёта рамки и тени
 const u8 items;                // количество пунктов меню
 PGM_VOID_P bkgnd_task;         // ссылка на фоновую задачу
 const u16 bgtask_period;       // период вызова фоновой задачи, мс (1..16383)
 PGM_VOID_P handlers;           // указатель на структуру указателей на обработчики
 PGM_U8_P strings;              // указатель на текст меню
} MENU_DESC;


void scr_set_attr(u8 attr);
void scr_set_cursor(u8 x, u8 y);
void scr_print_msg(PGM_U8_P msg);
void scr_print_mlmsg(PGM_U8_P *mlmsg);
void scr_print_msg_n(PGM_U8_P msg, u8 size);
void scr_print_rammsg_n(u8 *msg, u8 size);
void scr_putchar(u8 ch);
void scr_fill_char(u8 ch, u16 count);
void scr_fill_char_attr(u8 ch, u8 attr, u16 count);
void scr_fill_attr(u8 attr, u16 count);
void scr_backgnd(void);
void scr_fade(void);
void scr_window(PGM_VOID_P ptr);
void scr_menu(PGM_VOID_P ptr);

#endif
