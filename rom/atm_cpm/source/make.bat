@ECHO OFF

..\..\..\tools\asw\bin\asw -U -L rbios.a80
..\..\..\tools\asw\bin\p2bin rbios.p ..\rbios.rom -r $-$ -k

pause