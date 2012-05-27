@ECHO OFF

cd fat\source

..\..\..\tools\asw\bin\asw -cpu z80undoc -U -L make_micro_boot_fat.a80
..\..\..\tools\asw\bin\p2bin make_micro_boot_fat.p micro_boot_fat.rom -r $-$ -k
..\..\..\tools\mhmt\mhmt -mlz micro_boot_fat.rom micro_boot_fat_pack.rom

cd ..\..\page0\source

..\..\..\tools\asw\bin\asw -cpu z80undoc -U -L main.a80
..\..\..\tools\asw\bin\p2bin main.p main.rom -r $-$ -k

..\..\..\tools\asw\bin\asw -cpu z80undoc -U -L make_cmosset.a80
..\..\..\tools\asw\bin\p2bin make_cmosset.p cmosset.rom -r $-$ -k

..\..\..\tools\mhmt\mhmt -mlz main.rom main_pack.rom
..\..\..\tools\mhmt\mhmt -mlz cmosset.rom cmosset_pack.rom
..\..\..\tools\mhmt\mhmt -mlz chars_eng.bin chars_pack.bin

..\..\..\tools\asw\bin\asw -cpu z80undoc -U -L services.a80
..\..\..\tools\asw\bin\p2bin services.p ..\services.rom -r $-$ -k

del main.rom
del cmosset.rom
del main_pack.rom
del cmosset_pack.rom
del ..\..\fat\source\micro_boot_fat.rom

cd ..\..\page1\source

..\..\..\tools\asw\bin\asw -cpu z80undoc -L evo-dos_emu3d13.a80
..\..\..\tools\asw\bin\p2bin evo-dos_emu3d13.p ..\evo-dos_emu3d13.rom -r $-$ -k

..\..\..\tools\asw\bin\asw -cpu z80undoc -L evo-dos_virt.a80
..\..\..\tools\asw\bin\p2bin evo-dos_virt.p ..\evo-dos_virt.rom -r $-$ -k

cd ..\..\page2\source

..\..\..\tools\asw\bin\asw -cpu z80undoc -U -L spec128_0.a80
..\..\..\tools\asw\bin\p2bin spec128_0.p ..\basic128.rom -r $-$ -k

cd ..\..\page3\source

..\..\..\tools\asw\bin\asw -cpu z80undoc -U -L make_bas48_128.a80
..\..\..\tools\asw\bin\p2bin make_bas48_128.p ..\basic48.rom -r $-$ -k

cd ..\..\page5\source

..\..\..\tools\mhmt\mhmt -mlz 8x8_ar.fnt 8x8_ar_pack.bin
..\..\..\tools\mhmt\mhmt -mlz 866_code.fnt 866_code_pack.bin
..\..\..\tools\mhmt\mhmt -mlz atm_code.fnt atm_code_pack.bin
..\..\..\tools\asw\bin\asw -cpu z80undoc -U -L rst8service.a80
..\..\..\tools\asw\bin\p2bin rst8service.p ..\rst8service.rom -r $-$ -k
del 8x8_ar_pack.bin
del 866_code_pack.bin
del atm_code_pack.bin


cd ..\..\profrom\source

..\..\..\tools\asw\bin\asw -U -L -s make_evoprofrom.a80
..\..\..\tools\asw\bin\p2bin make_evoprofrom.p ..\evoprofrom.rom -r $-$ -k

cd ..\..

copy /B /Y ff_64k.rom+ff_64k.rom+ff_64k.rom+page3\2006.rom+page1\dos6_12e_patch.rom+page2\basic128.rom+page0\glukpen.rom+profrom\evoprofrom.rom+page3\basic48.rom+page1\evo-dos_virt.rom+page5\rst8service.rom+page3\basic48.rom+page1\evo-dos_emu3d13.rom+page2\basic128.rom+page0\services.rom zxevo.rom

copy /B /Y zxevo.rom ..\tools\unreal_fix\0.37.6\fix_build\x32\zxevo.rom
copy /B /Y zxevo.rom d:\unrealspeccy\zxevo.rom

pause
