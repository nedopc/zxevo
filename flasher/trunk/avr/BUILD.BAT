@echo on
if exist fpga.mlz del /f /q fpga.mlz
if exist fpga.inc del /f /q fpga.inc
if exist zxevo_fw.bin del /f /q zxevo_fw.bin
if exist flasher.zip del /f /q flasher.zip
..\..\..\tools\mhmt\mhmt.exe -mlz -maxwin4096 ..\fpga\main.rbf fpga.mlz
..\..\..\tools\bin2avr\bin2avr.exe fpga.mlz
..\..\..\tools\avrasm\avrasm32.exe -fI evoflash.asm -l evoflash.lst
if exist evoflash.hex ..\..\..\tools\make_fw\trunk\release\make_fw.exe evoflash.hex version.txt

if exist zxevo_fw.bin ..\..\..\tools\7z\7z.exe a -tzip -mx=9 flasher.zip zxevo_fw.bin
