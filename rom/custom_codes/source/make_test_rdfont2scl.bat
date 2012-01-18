@ECHO OFF

..\..\..\tools\asw\bin\asw -cpu z80undoc -U -L test_rdfont.a80
..\..\..\tools\asw\bin\p2bin test_rdfont.p test_rdfont.rom -r $-$ -k
..\..\..\tools\mhmt\mhmt -mlz test_rdfont.rom test_rdfont_pack.rom

..\..\..\tools\asw\bin\asw -cpu z80undoc -U -L make_test_rdfont2scl.a80
..\..\..\tools\asw\bin\p2bin make_test_rdfont2scl.p make_test_rdfont2scl.rom -r $-$ -k

..\..\..\tools\csum32\csum32 test_rdfont_pack.rom
copy /B /Y make_test_rdfont2scl.rom+csum32.bin ..\test_rdfont.scl

del csum32.bin

pause