@ECHO OFF

..\..\..\tools\asw\bin\asw -cpu z80undoc -U -L test_gluk_pages.a80
..\..\..\tools\asw\bin\p2bin test_gluk_pages.p test_gluk_pages.rom -r $-$ -k
..\..\..\tools\mhmt\mhmt -mlz test_gluk_pages.rom test_gluk_pages_pack.rom

..\..\..\tools\asw\bin\asw -cpu z80undoc -U -L make_testgp2scl.a80
..\..\..\tools\asw\bin\p2bin make_testgp2scl.p make_testgp2scl.rom -r $-$ -k

..\..\..\tools\csum32\csum32 test_gluk_pages_pack.rom
copy /B /Y make_testgp2scl.rom+csum32.bin ..\testgp.scl

del csum32.bin

pause