
@ECHO OFF

..\..\..\tools\asw\bin\asw -U -L make_bas48_128.a80
..\..\..\tools\asw\bin\p2bin make_bas48_128.p ..\basic48.rom -r $-$ -k

pause