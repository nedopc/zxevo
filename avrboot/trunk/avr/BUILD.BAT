@echo on
set prjname=BOOT_EVO
if exist zxevo_bl.hex del /f /q zxevo_bl.hex
..\..\..\tools\avrasm\avrasm32.exe -fI %prjname%.asm -l %prjname%.lst
if exist %prjname%.hex ..\..\..\tools\crcbldr\trunk\release\crcbldr.exe %prjname%.hex
if exist %prjname%.hex del /f /q %prjname%.hex
set prjname=