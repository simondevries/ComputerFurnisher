call config.bat
call updateComputerFurnisher.bat 

TITLE "COMPUTER FURNISHER"

cd /D %LocalFolderPath%
SET silent=false
if [%1]==silent (SET silent=true)

Powershell.exe -executionpolicy bypass -File %LocalFolderEntryPointPS% -argumentList '-logFolder %LogFolder% -SharedFolder %SharedFolder% -softwareInstallFolder %SoftwareFolder% -silent %silent%'

REM Todo sdv - there should be a nice way of doing this?
REM When computer furnisher needs deleting then it will create a file to indicate it needs deleting
IF exist %LocalFolderDeleteFileFlag% CALL :RemoveComputerFurnisher

EXIT /B


:RemoveComputerFurnisher
TIMEOUT /T 3
cd /D %LocalDrive%
del /S /F /Q %LocalFolderPath%
EXIT /B