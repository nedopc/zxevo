@ECHO OFF

..\..\..\tools\sjasmplus\sjasmplus --sym=sym.log --lst=dump.log -isrc make_main.a80

rem ..\mhmt -mlz filename.rom filename_pack.rom

pause