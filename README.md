
        ___.--------'``````:``````'--------.___
       ( C O M P U T E R   : F U R N I S H E R )
        \ ,;,,,            :               |  /
         |\%%%%\___________:__________/~~~~~/|
        / ,\%%%%\          |         / @*@ /, \
       /_ / `````          |         ~~~~~~ \ _\
      (@l)                 |                 (@l)
       ||__________________|__________________||
       ||_____________________________________||
      /_|_____________________________________|_\ ldb

Computer Furnisher is a tool to assist with the configuration of workstations according to the needs of each users specific. From 3 minutes of configuration, complex computer configuration can be setup. It exists to optimize the work of an IT support specialist by easily defining a job for a computer which contains a set of tasks to be performed such as installing software, updatings drivers, windows, bitlocker and execution of custom scrips on computers. It supports logging to a centralized location so it's progress can be tracked.

Easily write and register your own tasks to run on computers and leave the worrying about the execution of those tasks upto computer furnisher.

#Prerequisite
> A shared folder on the computer network where this script and all its resources can be accessed from.
> Knowledge of powershell
> Local administrator access- whole program runs as local admin
> Tested on windows 7 (not yet on windows 10)
> Dell computers (for using dell update module)


#Setup
> Create a folder on your shared drive which only administrator and a computerFurnisher user have access to (create new user to handle this)
> Copy contents of this folder into that shared location
> Open config.bat and update the variables below:
SharedDrive: Name of drive for shared folder
SharedDriveLetter: Same as above
SharedDriveAddress: UNC path to folder
SharedFolder: Location of shared folder if it is not in the root of the drive
FileServerName: Name of server shared drive is on (used to ensure the server is up and running)
PrintServer: Name of print server for adding printers
OfficeKey: Microsoft office key
LocalDrive: Computer furnisher is copied locally before run.
LocalFolderPath: Path of computer furnisher if not in root of local drive
ShareUser: The name of the user which was created to access the shared folder. This is used to copy the file to the local drive.
SharePassword: The password of the share user created to access the shared folder.
> Write a script that runs  go.bat