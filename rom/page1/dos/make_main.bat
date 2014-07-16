@ECHO OFF

asw -U -L make_trdos.a80
p2bin make_trdos.p ..\trdos.rom -r $-$ -k

asw -U -L make_evodos.a80
p2bin make_evodos.p ..\evodos.rom -r $-$ -k

rem del *.lst

pause