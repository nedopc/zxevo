call clean.bat
@echo on
..\..\..\tools\mhmt\mhmt.exe -mlz -maxwin4096 ..\..\..\avrboot\trunk\fpga\main.rbf fpga.mlz
..\..\..\tools\bin2avr\bin2avr.exe fpga.mlz
..\..\..\tools\avra\avra.exe -fI SDLOGGER.asm -l SDLOGGER.lst
if not exist SDLOGGER.hex goto err
..\..\..\tools\make_fw\make_fw.exe SDLOGGER.hex SDLOGGER.eep.hex zxevo_fw.bin version.txt %1
del /f /q SDLOGGER.hex
:err