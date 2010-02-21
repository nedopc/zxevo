@ECHO OFF

rem тестовая сборка настройщика CMOS

..\..\..\tools\sjasmplus\sjasmplus --sym=sym.log --lst=dump.log -isrc make_cmosset.a80

..\..\..\tools\mhmt\mhmt -mlz cmosset.rom cmosset_pack.rom

pause