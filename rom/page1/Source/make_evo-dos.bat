@ECHO OFF

..\..\..\tools\asw\bin\asw -cpu z80undoc -L evo-dos.a80
..\..\..\tools\asw\bin\p2bin evo-dos.p ..\evo-dos.rom -r $-$ -k

copy /B /Y ..\evo-dos.rom d:\unrealspeccy\

pause