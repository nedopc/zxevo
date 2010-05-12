@ECHO OFF

rem тестовая сборка микро бута с фата

..\..\..\tools\sjasmplus\sjasmplus --sym=sym.log --lst=dump.log -isrc make_micro_boot_fat.a80

..\..\..\tools\mhmt\mhmt -mlz micro_boot_fat.rom micro_boot_fat_pack.rom

pause