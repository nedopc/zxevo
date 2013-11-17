@ECHO OFF

cd ..\..\fat_boot\source

..\..\..\tools\asw\bin\asw -U -L make_micro_boot_fat.a80
..\..\..\tools\asw\bin\p2bin make_micro_boot_fat.p micro_boot_fat.rom -r $-$ -k

..\..\..\tools\mhmt\mhmt -mlz micro_boot_fat.rom micro_boot_fat_pack.rom

cd ..\..\page5\source

..\..\..\tools\mhmt\mhmt -mlz 8x8_ar.fnt 8x8_ar_pack.bin
..\..\..\tools\mhmt\mhmt -mlz 866_code.fnt 866_code_pack.bin
..\..\..\tools\mhmt\mhmt -mlz atm_code.fnt atm_code_pack.bin
..\..\..\tools\mhmt\mhmt -mlz perfpack.bin perfpack_pack.bin

..\..\..\tools\asw\bin\asw -U -L rst8service.a80
..\..\..\tools\asw\bin\p2bin rst8service.p ..\rst8service.rom -r $-$ -k

del 8x8_ar_pack.bin
del 866_code_pack.bin
del atm_code_pack.bin

pause