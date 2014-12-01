@ECHO OFF

..\..\..\tools\asw\bin\asw -U -L micro_boot_fat.a80
..\..\..\tools\asw\bin\p2bin micro_boot_fat.p micro_boot_fat.rom -r $-$ -k

..\..\..\tools\mhmt\mhmt -mlz micro_boot_fat.rom micro_boot_fat_pack.rom

pause