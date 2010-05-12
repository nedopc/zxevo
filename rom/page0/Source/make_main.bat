@ECHO OFF

rem тестовая сборка основного куска сервиса

..\..\..\tools\sjasmplus\sjasmplus --sym=sym.log --lst=dump.log -isrc make_micro_boot_fat.a80

..\..\..\tools\sjasmplus\sjasmplus --sym=sym.log --lst=dump.log -isrc make_main.a80
..\..\..\tools\mhmt\mhmt -mlz main.rom main_pack.rom

pause