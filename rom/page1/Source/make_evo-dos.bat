@ECHO OFF

..\..\..\tools\asw\bin\asw -cpu z80undoc -L evo-dos_emu3d13.a80
..\..\..\tools\asw\bin\p2bin evo-dos_emu3d13.p ..\evo-dos_emu3d13.rom -r $-$ -k

rem ..\..\..\tools\asw\bin\asw -cpu z80undoc -L evo-dos_real.a80
rem ..\..\..\tools\asw\bin\p2bin evo-dos_real.p ..\evo-dos_real.rom -r $-$ -k

rem ..\..\..\tools\asw\bin\asw -cpu z80undoc -L evo-dos_virt.a80
rem ..\..\..\tools\asw\bin\p2bin evo-dos_virt.p ..\evo-dos_virt.rom -r $-$ -k

copy /B /Y ..\evo-dos_real.rom d:\unrealspeccy\

pause