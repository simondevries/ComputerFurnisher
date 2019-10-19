call config.bat

cd /D %LocalDrive%
rmdir /S /Q %LocalFolderPath%
net use %SharedDrive% %SharedDriveAddress%
ROBOCOPY /XO /S "%ComputerFurnisherFolder%" "%LocalFolderPath%" >nul 2>&1