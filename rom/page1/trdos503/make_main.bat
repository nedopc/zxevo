@ECHO OFF

asw -L tr_503.a80
p2bin tr_503.p ..\tr_503.rom -r $-$ -k

rem del *.lst

pause