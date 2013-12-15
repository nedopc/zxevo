@ECHO OFF

..\..\..\tools\asw\bin\asw -U -L trdos_v6.a80
..\..\..\tools\asw\bin\p2bin trdos_v6.p ..\dosatm3.rom -r $-$ -k

pause