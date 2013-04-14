#ifndef _MESSAGES_H
#define _MESSAGES_H

#define TOTAL_LANG 2

#include "_types.h"

//-----------------------------------------------------------------------------

extern const u8 msg_title1[] PROGMEM;
extern const u8 msg_title2[] PROGMEM;
extern PGM_U8_P mlmsg_pintest[] PROGMEM;
extern PGM_U8_P mlmsg_pintest_ok[] PROGMEM;
extern PGM_U8_P mlmsg_pintest_error[] PROGMEM;
extern const u8 msg_pintest_pa[] PROGMEM;
extern const u8 msg_pintest_pb[] PROGMEM;
extern const u8 msg_pintest_pc[] PROGMEM;
extern const u8 msg_pintest_pd[] PROGMEM;
extern const u8 msg_pintest_pe[] PROGMEM;
extern const u8 msg_pintest_pf[] PROGMEM;
extern const u8 msg_pintest_pg[] PROGMEM;
extern PGM_U8_P mlmsg_halt[] PROGMEM;
extern PGM_U8_P mlmsg_statusof_crlf[] PROGMEM;
extern PGM_U8_P mlmsg_statusof_cr[] PROGMEM;
extern const u8 msg_power_pg[] PROGMEM;
extern const u8 msg_power_vcc5[] PROGMEM;
extern PGM_U8_P mlmsg_power_on[] PROGMEM;
extern PGM_U8_P mlmsg_cfgfpga[] PROGMEM;
extern PGM_U8_P mlmsg_done1[] PROGMEM;
extern const u8 msg_ok[] PROGMEM;
extern PGM_U8_P mlmsg_someerrors[] PROGMEM;
extern PGM_U8_P mlmsg_spi_test[] PROGMEM;
extern PGM_U8_P mlmsg_kbd_detect[] PROGMEM;
extern PGM_U8_P mlmsg_noresponse[] PROGMEM;
extern PGM_U8_P mlmsg_unwanted[] PROGMEM;
extern PGM_U8_P mlmsg_txfail[] PROGMEM;
extern const u8 msg_ready[] PROGMEM;
extern PGM_U8_P mlmsg_menu_help[] PROGMEM;
extern PGM_U8_P mlmsg_tbeep[] PROGMEM;
extern PGM_U8_P mlmsg_tzxk1[] PROGMEM;
extern const u8 msg_tzxk2[] PROGMEM;
extern PGM_U8_P mlmsg_tps2k0[] PROGMEM;
extern const u8 msg_tps2k1[] PROGMEM;
extern PGM_U8_P mlmsg_mouse_test[] PROGMEM;
extern PGM_U8_P mlmsg_mouse_detect[] PROGMEM;
extern PGM_U8_P mlmsg_mouse_setup[] PROGMEM;
extern PGM_U8_P mlmsg_mouse_letsgo[] PROGMEM;
extern PGM_U8_P mlmsg_mouse_fail0[] PROGMEM;
extern PGM_U8_P mlmsg_mouse_fail1[] PROGMEM;
extern PGM_U8_P mlmsg_mouse_restart[] PROGMEM;
extern const u8 msg_tpsm_1[] PROGMEM;
extern PGM_U8_P mlmsg_mtst[] PROGMEM;
extern PGM_U8_P mlmsg_menu_swlng[] PROGMEM;
extern PGM_U8_P mlmsg_fl_menu[] PROGMEM;
extern PGM_U8_P mlmsg_fp_nofiles[] PROGMEM;
extern PGM_U8_P mlmsg_fl_readrom[] PROGMEM;
extern PGM_U8_P mlmsg_fl_sdinit[] PROGMEM;
extern PGM_U8_P mlmsg_fl_sderror1[] PROGMEM;
extern PGM_U8_P mlmsg_fl_sderror2[] PROGMEM;
extern PGM_U8_P mlmsg_fl_sderror3[] PROGMEM;
extern PGM_U8_P mlmsg_fl_sderror4[] PROGMEM;
extern PGM_U8_P mlmsg_fl_sure[] PROGMEM;
extern PGM_U8_P mlmsg_fl_erase[] PROGMEM;
extern PGM_U8_P mlmsg_fl_write[] PROGMEM;
extern PGM_U8_P mlmsg_fl_verify[] PROGMEM;
extern PGM_U8_P mlmsg_fl_complete[] PROGMEM;
extern PGM_U8_P mlmsg_flres0[] PROGMEM;
extern PGM_U8_P mlmsg_flres1[] PROGMEM;
extern PGM_U8_P mlmsg_flres2[] PROGMEM;
extern PGM_U8_P mlmsg_sensors[] PROGMEM;
extern PGM_U8_P mlmsg_s_nocard[] PROGMEM;
extern PGM_U8_P mlmsg_s_inserted[] PROGMEM;
extern PGM_U8_P mlmsg_s_readonly[] PROGMEM;
extern PGM_U8_P mlmsg_s_writeen[] PROGMEM;
extern PGM_U8_P mlmsg_tsd_init[] PROGMEM;
extern PGM_U8_P mlmsg_tsd_nocard[] PROGMEM;
extern PGM_U8_P mlmsg_tsd_foundcard[] PROGMEM;
extern PGM_U8_P mlmsg_tsd_menu[] PROGMEM;
extern PGM_U8_P mlmsg_tsd_foundfat[] PROGMEM;
extern PGM_U8_P mlmsg_tsd_detect[] PROGMEM;
extern PGM_U8_P mlmsg_tsd_readfile[] PROGMEM;
extern PGM_U8_P mlmsg_tsd_complete[] PROGMEM;
extern const u8 msg_trs_1[] PROGMEM;

extern const u8 str_menu_main[] PROGMEM;

//-----------------------------------------------------------------------------

#endif
