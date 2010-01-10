if exist fpga2.mlz del /f /q fpga2.mlz
if exist fpga2.inc del /f /q fpga2.inc
..\..\..\tools\mhmt\mhmt.exe -mlz -maxwin4096 ..\fpga2\main.rbf fpga2.mlz
..\..\..\tools\bin2avr\bin2avr.exe fpga2.mlz
..\..\..\tools\avrasm\avrasm32.exe -fI TRYFLASH.asm -l TRYFLASH.lst
