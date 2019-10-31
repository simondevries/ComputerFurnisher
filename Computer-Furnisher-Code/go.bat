cd %1

call .\config.bat
call .\updateComputerFurnisher.bat

TITLE COMPUTER FURNISHER

net use %SharedDrive% %SharedDriveAddress% /user:%ShareUser% %SharePassword%

cd /D %LocalFolderPath%
SET silent=false
if [%2]==[silent] (SET silent=true)
Powershell.exe -executionpolicy bypass -File %LocalFolderEntryPointPS% -argumentList '-softwareInstallFolder %SoftwareFolder% -silent %silent%'

IF exist %LocalFolderDeleteFileFlag% CALL :RemoveComputerFurnisher
TIMEOUT /T 3
PAUSE
EXIT /B


:RemoveComputerFurnisher
cd /D "%LocalDrive%/"
REM Ensure delete functionality works
rmdir "%LocalFolderPath%" /S /Q 
