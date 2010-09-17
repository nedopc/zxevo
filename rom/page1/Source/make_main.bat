@ECHO OFF

..\..\..\tools\asw\bin\asw -cpu z80undoc -L main.a80
..\..\..\tools\asw\bin\p2bin main.p evo_dos.rom -r $-$ -k

pause