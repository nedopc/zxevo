
@ECHO OFF

..\..\..\tools\asw\bin\asw -U -L basic48.a80
..\..\..\tools\asw\bin\p2bin basic48.p ..\basic48_128.rom -r $-$ -k
 
pause