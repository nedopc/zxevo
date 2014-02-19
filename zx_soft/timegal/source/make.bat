@ECHO OFF

..\..\..\tools\asw\bin\asw -U -L timegal_atm.a80
..\..\..\tools\asw\bin\p2bin timegal_atm.p timegal.rom -r $-$ -k

..\..\..\tools\mhmt\mhmt -mlz timegal.rom timegal_pack.rom

..\..\..\tools\asw\bin\asw -U -L make_hobeta.a80
..\..\..\tools\asw\bin\p2bin make_hobeta.p ..\timegal_atm.$C -r $-$ -k

..\..\..\tools\asw\bin\asw -U -L timegal_evo.a80
..\..\..\tools\asw\bin\p2bin timegal_evo.p timegal.rom -r $-$ -k

..\..\..\tools\mhmt\mhmt -mlz timegal.rom timegal_pack.rom

..\..\..\tools\asw\bin\asw -U -L make_hobeta.a80
..\..\..\tools\asw\bin\p2bin make_hobeta.p ..\timegal_evo.$C -r $-$ -k

del *.lst
del *.rom

pause
