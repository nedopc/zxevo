@ECHO OFF

..\..\..\tools\asw\bin\asw -cpu z80undoc -L tr503.a80
..\..\..\tools\asw\bin\p2bin tr503.p tr503.bin -r $-$ -k

copy /B /Y TR503.BIN d:\unrealspeccy\

pause