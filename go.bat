call config.bat
call updateComputerFurnisher.bat 

TITLE "COMPUTER FURNISHER"

cd /D %LocalFolderPath%
SET silent=false
if [%1]==[silent] (SET silent=true)

Powershell.exe -executionpolicy bypass -File %LocalFolderEntryPointPS% -argumentList '-SharedFolder %SharedFolder% -softwareInstallFolder %SoftwareFolder% -silent %silent%'

IF exist %LocalFolderDeleteFileFlag% CALL :RemoveComputerFurnisher

EXIT /B


:RemoveComputerFurnisher
TIMEOUT /T 3
cd /D %LocalDrive%
del /S /F /Q %LocalFolderPath%
EXIT /B