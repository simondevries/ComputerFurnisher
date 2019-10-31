call config.bat

net use %SharedDrive% %SharedDriveAddress% /user:%ShareUser% %SharePassword%
ROBOCOPY /XO /S "%ComputerFurnisherFolder%" "%LocalFolderPath%" >nul 2>&1