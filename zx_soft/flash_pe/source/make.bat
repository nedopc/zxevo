@ECHO OFF

..\..\..\tools\asw\bin\asw -U -L flash_pe.a80
..\..\..\tools\asw\bin\p2bin flash_pe.p flash_pe.rom -r $-$ -k

..\..\..\tools\mhmt\mhmt -mlz flash_pe.rom flash_pe_pack.rom

..\..\..\tools\asw\bin\asw -U -L make_scl.a80
..\..\..\tools\asw\bin\p2bin make_scl.p make_scl.rom -r $-$ -k

..\..\..\tools\csum32\csum32 make_scl.rom
copy /B /Y make_scl.rom+csum32.bin ..\flash_pe.scl

..\..\..\tools\asw\bin\asw -U -L make_hobeta.a80
..\..\..\tools\asw\bin\p2bin make_hobeta.p ..\flash_pe.$C -r $-$ -k

del csum32.bin
del *.rom
del *.lst

pause