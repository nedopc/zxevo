@ECHO OFF

..\..\..\tools\asw\bin\asw -U -L evo-dos_emu3d13.a80
..\..\..\tools\asw\bin\p2bin evo-dos_emu3d13.p ..\evo-dos_emu3d13.rom -r $-$ -k

..\..\..\tools\asw\bin\asw -U -L evo-dos_virt.a80
..\..\..\tools\asw\bin\p2bin evo-dos_virt.p ..\evo-dos_virt.rom -r $-$ -k

pause