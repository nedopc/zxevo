call clean.bat
@echo on
..\..\..\tools\mhmt\mhmt.exe -mlz -maxwin4096 ..\fpga\main.rbf fpga.mlz
..\..\..\tools\bin2avr\bin2avr.exe fpga.mlz
..\..\..\tools\avra\avra.exe -fI evoflash.asm -l evoflash.lst
if not exist evoflash.hex goto err
..\..\..\tools\make_fw\trunk\release\make_fw.exe evoflash.hex version.txt
rem del /f /q evoflash.hex
..\..\..\tools\7z\7z.exe a -tzip -mx=9 flasher.zip zxevo_fw.bin
:err