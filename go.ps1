# Most of these can be removed

param (
    [string]$logFolder,
    [string]$homeFolder,
    [string]$resourcesFolder,
    [string]$validationOnly,
    [string]$silent
)

Import-Module -name "./Libraries/PSWindowsUpdate/Get-WUInstall.ps1" -force
Import-Module -name "./Libraries/PSWindowsUpdate/Get-WUList.ps1" -force
Import-Module -name './tools.ps1' -force
Import-Module -name './io.ps1' -force
Import-Module -name './printer.ps1' -force
Import-Module -name './_setupTeamViewer.ps1' -force
Import-Module -name './_windowsUpdate.ps1' -force
Import-Module -name './_softwareInstallation.ps1' -force
Import-Module -name './_activateOffice.ps1' -force
Import-Module -name './_updateDrivers.ps1' -force
Import-Module -name './_addPrinters.ps1' -force
Import-Module -name './_addDelProf.ps1' -force
Import-Module -name './defaultJob.ps1' -force
Import-Module -name './defaultStatus.ps1' -force

function Display-Warning {
    $a = $global:status.HasAcceptedWarning
    if ($global:status.HasAcceptedWarning -eq $TRUE) {
        return
    }
 
    $result = Read-Host "This program performs maintenance on PC's by updating windows, software, drivers and makes configuration changes to make it operate on the Mercy Ships IT infrastructure. Do not run this unless you know it's intended purpose. Would you like to proceed? (Y)es (N)o"
    if($result.ToLower() -eq "y") {
        $Wha = $global:status
        $global:status.HasAcceptedWarning = $TRUE
        Upsert-File-From-Object $global:status "$logFolder/$env:StatusFileName"
    } else {
        Write-Host "Exiting"
        Exit
    }
}

function Run-With-Retry ([scriptblock] $func, [boolean] $shouldExecute, [Object] $statusOfCurrentTask, [Object] $pOne, [Object] $pTwo) {
    if($statusOfCurrentTask -eq $NULL) {throw "Null param"}
    
    $taskName = $statusOfCurrentTask.Name
    $taskStatus = $statusOfCurrentTask.Status
    if ($shouldExecute -eq $FALSE) {
        return
    }

    if ($taskStatus.ToLower() -ne "new" -and $taskStatus.ToLower() -ne "success (rerunnable)") {
        Write-Host "Skipping $taskName as it has the status of $taskStatus"
        return
    }

    Write-Host "Validating task $taskName"
    
    $cmdInput = $NULL
    
    #todo silent mode

    do {
        $validationStatus = ""
        Try{
            $validationStatus = & $func $global:status $pOne $pTwo
            $taskStatus = "Passed Validation"
        } Catch {
            $statusOfCurrentTask.Reason = $_
            $statusOfCurrentTask.Status = "Failed Validation"
            Write-Host "Task $taskName failed with the following error: $_"
            if ($global:silent.ToLower() -eq "true"){
                $cmdInput = "S"
            } else {
                $cmdInput = Read-Host "Press enter to try again, press S to skip?"
            }
        }

        Upsert-File-From-Object $global:status "$logFolder/$env:StatusFileName"

    } while (($statusOfCurrentTask.Status -eq "failed validation" -and ($cmdInput -eq $NULL -or $cmdInput.ToLower() -ne 's')))
}

Function Run-Validation {


    Write-Host -ForegroundColor DarkGreen "=== Validating tasks ==="
    Run-With-Retry ${function:Windows-Update-Run-Validation} $global:job.Tasks.UpdateWindows $global:status.Tasks.UpdateWindows 
    #For now software install needs to run first to ensure dell command can run
    Run-With-Retry ${function:Software-Installation-Run-Validation} $global:job.Tasks.SoftwareInstallation $global:status.Tasks.SoftwareInstallation $global:job.SoftwareToInstall
    Run-With-Retry ${function:Update-Drivers-Run-Validation} $global:job.Tasks.UpdateDrivers $global:status.Tasks.UpdateDrivers
    Run-With-Retry ${function:Update-Office-Run-Validation} $global:job.Tasks.ActivateOffice $global:status.Tasks.ActivateOffice
    Run-With-Retry ${function:Add-Printer-Run-Validation} $global:job.Tasks.AddPrinters $global:status.Tasks.AddPrinters
    Run-With-Retry ${function:Add-DelProf-Validation} $global:job.Tasks.AddDelProf $global:status.Tasks.AddDelProf
    
    Write-Host -ForegroundColor DarkGreen "=== Done Validating tasks ==="
}

Function Run-Task ([scriptblock] $func, [object] $statusOfCurrentTask, [boolean] $shouldExecute, [object] $pOne) {


    $taskName = $statusOfCurrentTask.Name
    $taskStatus = $statusOfCurrentTask.Status
    if ($shouldExecute -eq $FALSE) {
        # Write-Host "Skipping $taskName as it is marked as disabled on job.xml"
        return
    }
    if ($taskStatus.ToLower() -ne "new" -and $taskStatus.ToLower() -ne "success (rerunnable)") {
        Write-Host "Skipping $taskName as it has the status of $taskStatus"
        return
    }
    # Function Install-Specified-Software([object] $status, [string] $softwareToInstall) {
    #consider passing in the status of the item and handling success and failure automatically based off whether an error was thrown
    
    Write-Host "Running task $taskName"
    Try {
        $result = & $func $global:status $pOne
        Write-Host "Successfully completed task: $taskName"
        if ($statusOfCurrentTask.Status -ne "Success (rerunnable)") {
            $statusOfCurrentTask.Status = "Success"
        }
        $statusOfCurrentTask.Reason = ""
    } Catch {
        Write-Host "An error occured when executing $taskName: $_"
        $statusOfCurrentTask.Status = "Error"
        $statusOfCurrentTask.Reason = "$_"
    }
    Upsert-File-From-Object $global:status "$logFolder/$env:StatusFileName"
}


Function Run-Tasks {
    if ($validationOnly -eq "true") {
        Write-Host "Skipping task run as program was run with flag 'validation'"
        return
    }
    Write-Host -ForegroundColor DarkGreen "=== Running tasks ==="
    Run-Task ${function:Software-Installation} $global:status.Tasks.SoftwareInstallation $global:job.Tasks.SoftwareInstallation 
    Run-Task ${function:Activate-Office} $global:status.Tasks.ActivateOffice $global:job.Tasks.ActivateOffice
    Run-Task ${function:Add-Printers} $global:status.Tasks.AddPrinters $global:job.Tasks.AddPrinters $global:job.PrintersToAdd
    Run-Task ${function:Add-DelProf} $global:status.Tasks.AddDelProf $global:job.Tasks.AddDelProf
    Run-Task ${function:Update-Drivers} $global:status.Tasks.UpdateDrivers $global:job.Tasks.UpdateDrivers
    Run-Task ${function:Update-Windows} $global:status.Tasks.UpdateWindows $global:job.Tasks.UpdateWindows
    Write-Host -ForegroundColor DarkGreen "=== Done running tasks ==="
}

Function Cleanup-When-Required {
    if ($global:status.NumberOfExecutions -lt 4) {
        return
    }

    Write-Host -ForegroundColor DarkGreen "Removing scheduled task and software folder as this has run 3 times"

    # can it be deleted when it is running as the task
    schtasks /Delete /TN "Computer Furnisher" /F
    
    Delete-Folder-And-Content-If-Exists $env:LocalFolderTempSoftware
    
    # This file triggers the bat file to delete folder
    echo "Delete flag, this will be deleted on completion" > $env:LocalFolderDeleteFileFlag
}


CLS
Write-host -ForegroundColor DarkGreen "==========================Computer Furnisher=============================="

$logFolder += "\$env:$env:computername"

if ($silent -eq "true"){
    Write-Host "Silent mode activated"
}

Start-Sleep -s 1
if (-NOT (Test-Connection -$env:computername $env:FileServerName -Quiet)) {
    Write-Host "Error cannot connect to $env:FileServerName. Trying again 20 seconds"
    Start-Sleep -s 20
    if (-NOT (Test-Connection -$env:computername $FileServerName -Quiet)) {
    	Write-Host "Still cannot connect to $env:FileServerName... ceasing execution :("
    	return
	}
}


# Todo (sdv) logs
# Write-Host "Software Install folder: $env:"
# Write-Host "Log folder: $logFolder"
# Write-Host "Job file name: $jobFileNameForPrint"
# Write-Host "Home folder: $homeFolder"


New-PSDrive -Name $env:SharedDrive -PSProvider "FileSystem" -Root $env:DriveRoot

# Setup #1 - create and validate files/folders

Validate-Folder-Exists $softwareInstallFolder "Software Install folder"
Create-Folder-If-Does-Not-Exist $logFolder
Validate-Folder-Exists $homeFolder "Job folder"

#checken or the egg... if I need to clear the status then I load a bad version this way around. Other way around I

# Check-Should-Delete-Status-File

# Setup #2 load status 
$global:status = Load-Status-From-File $logFolder $global:status

# Setup #3 Get job name
$jobFileNameForPrint = $global:status.JobFileName
if ($silent -ne "true"){
    $res = Read-Host "Enter the job file name you would like to use (default is job)(include .xml). Currently set to $jobFileNameForPrint. Press s skip and use currently set"
    if ($res -ne "s"){
        $global:status.JobFileName = $res
        $global:status.NumberOfExecutions = 0
    }
    
    $nOE = $global:status.NumberOfExecutions
    if ($nOE -gt 2){
        $res = Read-Host "Computer furnisher has already been run 3 times. Unless reset, the software will cleanup upon completion. Do you want to reset numer of executions to 0? (Y/N)"
        if ($res -eq "y"){
            $global:status.NumberOfExecutions = 0
        }
        Remove-Item -Path $env:LocalFolderDeleteFileFlag
    }
}

$global:job = Load-Job-From-File $homeFolder $global:job $global:status.JobFileName

# Setup #4 change power options to ensure we don't shutdown part way

C:\Windows\system32\powercfg.exe -change -standby-timeout-ac 0
C:\Windows\system32\powercfg.exe -change -hibernate-timeout-ac 0

# Setup #5 update last execution

$global:status.LastExecution = Get-Date -Format o
Upsert-File-From-Object $global:status "$logFolder/$env:StatusFileName"

# Setup #5 - Add scheduled task

$computerFurnisherScheduledTasks = schtasks | Select-String -Pattern 'Computer Furnisher'
if ($computerFurnisherScheduledTasks -eq $NULL -or $computerFurnisherScheduledTasks.count -eq 0) {
    # todo (sdv) cleanup should split home folder to jobFolder and software folder or sthng
    # looks like create scheduled task doesn't like it when run off the fileserver drive
    Write-Host "Importing scheduled task from $schedTaskFilePath, please enter DA credentials to run task as"
    $creds = Get-Credential
    schtasks /Create /XML $env:ComputerFurnisherScheduledTaskPath /RU $creds.UserName /RP $creds.GetNetworkCredential().Password /TN "Computer Furnisher"
}

# Run #1 - User warning

Display-Warning #should be after check should clear status

# Run #2 - Status

Print-Job-Status $global:job
$global:status.NumberOfExecutions = $global:status.NumberOfExecutions + 1
$numOfExecutions = $global:status.NumberOfExecutions
Write-Host "Number of executions: $numberOfExecutions"

# Run #3 validation and tasks

Run-Validation
Run-Tasks
Print-Result $global:status

# Cleanup #1 

C:\Windows\system32\powercfg.exe -change -standby-timeout-ac 15
C:\Windows\system32\powercfg.exe -change -hibernate-timeout-ac 30

# Cleanup #2 - If this is the last execution then cleanup

Write-Host "This is has been run " $global:status.NumberOfExecutions " times."
Upsert-File-From-Object $global:status "$logFolder/$env:StatusFileName"

Cleanup-When-Required

Write-Host "Power options have been reset. If running from a scheduled task, it will restart in 4 mintues..."

