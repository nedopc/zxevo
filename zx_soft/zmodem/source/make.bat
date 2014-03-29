@ECHO OFF

rem make for PentEvo
..\..\..\tools\asw\bin\asw -U -L main_evo.a80
..\..\..\tools\asw\bin\p2bin main_evo.p main_evo.rom -r $-$ -k

..\..\..\tools\mhmt\mhmt -mlz main_evo.rom main_evo_pack.rom

..\..\..\tools\asw\bin\asw -U -L make_scl_evo.a80
..\..\..\tools\asw\bin\p2bin make_scl_evo.p make_scl_evo.rom -r $-$ -k

..\..\..\tools\csum32\csum32 make_scl_evo.rom
copy /B /Y make_scl_evo.rom+csum32.bin ..\zmodem_evo.scl

..\..\..\tools\asw\bin\asw -U -L make_hobeta_evo.a80
..\..\..\tools\asw\bin\p2bin make_hobeta_evo.p ..\zmodem_evo.$C -r $-$ -k

rem make for Profi
..\..\..\tools\asw\bin\asw -U -L main_profi.a80
..\..\..\tools\asw\bin\p2bin main_profi.p main_profi.rom -r $-$ -k

..\..\..\tools\mhmt\mhmt -mlz main_profi.rom main_profi_pack.rom

..\..\..\tools\asw\bin\asw -U -L make_scl_profi.a80
..\..\..\tools\asw\bin\p2bin make_scl_profi.p make_scl_profi.rom -r $-$ -k

..\..\..\tools\csum32\csum32 make_scl_profi.rom
copy /B /Y make_scl_profi.rom+csum32.bin ..\zmodem_profi.scl

..\..\..\tools\asw\bin\asw -U -L make_hobeta_profi.a80
..\..\..\tools\asw\bin\p2bin make_hobeta_profi.p ..\zmodem_profi.$C -r $-$ -k

rem make for Pentagon 2.2
..\..\..\tools\asw\bin\asw -U -L main_pent22.a80
..\..\..\tools\asw\bin\p2bin main_pent22.p main_pent22.rom -r $-$ -k

..\..\..\tools\mhmt\mhmt -mlz main_pent22.rom main_pent22_pack.rom

..\..\..\tools\asw\bin\asw -U -L make_scl_pent22.a80
..\..\..\tools\asw\bin\p2bin make_scl_pent22.p make_scl_pent22.rom -r $-$ -k

..\..\..\tools\csum32\csum32 make_scl_pent22.rom
copy /B /Y make_scl_pent22.rom+csum32.bin ..\zmodem_pent22.scl

..\..\..\tools\asw\bin\asw -U -L make_hobeta_pent22.a80
..\..\..\tools\asw\bin\p2bin make_hobeta_pent22.p ..\zmodem_pent22.$C -r $-$ -k

del csum32.bin
del *.rom
del *.lst

pause