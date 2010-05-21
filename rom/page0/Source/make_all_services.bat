@ECHO OFF

rem полная сборка ПЗУ из всех кусков

..\..\..\tools\sjasmplus\sjasmplus -isrc make_micro_boot_fat.a80
..\..\..\tools\sjasmplus\sjasmplus -isrc make_main.a80
..\..\..\tools\sjasmplus\sjasmplus -isrc make_cmosset.a80

..\..\..\tools\mhmt\mhmt -mlz main.rom main_pack.rom
..\..\..\tools\mhmt\mhmt -mlz cmosset.rom cmosset_pack.rom

..\..\..\tools\sjasmplus\sjasmplus --lst=dump.log -isrc make_all_services.a80

pause

del micro_boot_fat.rom
del main.rom
del cmosset.rom

del main_pack.rom
del cmosset_pack.rom
