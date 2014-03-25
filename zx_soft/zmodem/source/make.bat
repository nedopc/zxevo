@ECHO OFF

..\..\..\tools\asw\bin\asw -U -L main.a80
..\..\..\tools\asw\bin\p2bin main.p main.rom -r $-$ -k

..\..\..\tools\mhmt\mhmt -mlz main.rom main_pack.rom

..\..\..\tools\asw\bin\asw -U -L make_scl.a80
..\..\..\tools\asw\bin\p2bin make_scl.p make_scl.rom -r $-$ -k

..\..\..\tools\csum32\csum32 make_scl.rom
copy /B /Y make_scl.rom+csum32.bin ..\zmodem_evo.scl

..\..\..\tools\asw\bin\asw -U -L make_hobeta.a80
..\..\..\tools\asw\bin\p2bin make_hobeta.p ..\zmodem_evo.$C -r $-$ -k

del csum32.bin
del *.rom
del *.lst

pause