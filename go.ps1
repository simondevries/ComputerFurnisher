# Most of these can be removed

param (
    [string]$homeFolder,
    [string]$resourcesFolder,
    [string]$validationOnly
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
            if ($env:silent.ToLower() -eq "true"){
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

Function Validate-Paths-Exist {
    Validate-Path-Exists $env:SharedFolder "Shared Folder"
    Validate-Path-Exists $env:SoftwareFolder "Shared Software Install folder"
    Validate-Path-Exists $env:ComputerFurnisherFolder "Shared Computer Furnisher Code Folder"
    Validate-Path-Exists $env:LocalFolderPath "Local Computer Furnisher Folder"
    Create-Folder-If-Does-Not-Exist $env:logFolder
    Validate-Path-Exists $env:LogFolder "Shared Log Folder"
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

Function Check-Server-Connection {
    Start-Sleep -s 1
    if (-NOT (Test-Connection -computername $env:FileServerName -Quiet)) {
        Write-Host "Error cannot connect to $env:FileServerName. Trying again 20 seconds"
        Start-Sleep -s 20
        if (-NOT (Test-Connection -computername $FileServerName -Quiet)) {
            Write-Host "Still cannot connect to $env:FileServerName... ceasing execution :("
            Exit
        }
    }
}
Function Map-Network-Drive {
    New-PSDrive -Name "$env:SharedDriveLetter" -PSProvider "FileSystem" -Root "$env:DriveRoot" | Out-Null
}

Function Determine-Job-Name {
    $jobFileName = $global:status.JobFileName

    if ($env:silent -eq "true") {
        Write-Host "Using existing job $jobFileName"
        Validate-Path-Exists "$env:SharedFolder/$jobFileName" $jobFileName
        return
    }
    if ($jobFileName -ne ""){ # if job file defined
        $path = "$env:SharedFolder/$jobName"
        $pathExists = Test-Path $path
        if ($pathExists -eq $FALSE) {
            Write-Host "Could not find a job called $jobFileName"
            Determine-Job-Name
            return
        }
        $res = Read-Host "This process has previous run using job $jobFileName. Hit E to edit the job, hit C to change or create job, hit Enter to continue with selected job"
        if($res.ToLower() -eq "c") {
            $global:status.JobFileName = ""
            Determine-Job-Name
        }
        if($res.ToLower() -eq "e") {
            Notepad.exe "$env:SharedFolder/$jobFileName" | Out-Null #Out-null causes powershell to wait till process killed
        }
        return
    }

    $res = Read-Host "This computer has not been assigned a job yet. Would you like to define a new job now based off jobTemplate.xml or would you like to use an existing one? (N for new, Type file name for existing)"
    if ($res.ToLower() -eq "n") {
        Validate-Path-Exists "$env:SharedFolder/jobTemplate.xml" "JobTemplate.xml"
        $jobName = Read-Host "Please specify new job name"
        $jobName  = $jobName -replace '.xml',''
        Write-Host "Creating..."
        Copy-Item "$env:SharedFolder/jobTemplate.xml" "$env:SharedFolder/$jobName.xml"
        $global:status.JobFileName = "$jobName.xml"
        $global:status.NumberOfExecutions = 0
    } else {
        $res  = $res -replace '.xml',''
        $path = "$env:SharedFolder/$res.xml"
        $pathExists = Test-Path $path
        if ($pathExists -eq $FALSE) {
            Write-Host -ForegroundColor red "Could not find a job called $res"
            Determine-Job-Name
            return
        }
        $global:status.JobFileName = "$res.xml"
        $global:status.NumberOfExecutions = 0
    }

    $jobFileName = $global:status.JobFileName
    Write-Host "Opening notepad so you can check settings... Close notepad to continue"
    Start-Sleep -s 1
    Notepad.exe "$env:SharedFolder/$jobFileName" | Out-Null #Out-null causes powershell to wait till process killed
}

Function Check-If-Wants-To-Reset-Number-Of-Executions() {
    if ($env:silent -eq "true"){
        return
    }

    if ($global:status.NumberOfExecutions -gt 2){
        $res = Read-Host "Computer furnisher has already been run 3 times, this means it will delete itself from this computer after completion. Hit (R) to reset counter to 0 and avoid deletion"
        if ($res -eq "r"){
            $global:status.NumberOfExecutions = 0
        }
        
        $pathExists = Test-Path $env:LocalFolderDeleteFileFlag
        if ($pathExists -eq $TRUE) {
            Remove-Item -Path $env:LocalFolderDeleteFileFlag | Out-Null
        }
    }
}

CLS
Write-host -ForegroundColor DarkGreen "=========================* Computer Furnisher - Setup *============================="

# Setup #1 
Check-Server-Connection
Print-Config-Paths
Print-Job-Status
Validate-Paths-Exist
Map-Network-Drive



# Setup #2 load status 
$logFolder += "$env:LogFolder\$env:computername"
$global:status = Load-Status-From-File $logFolder $global:status
Print-Current-Status

# Setup #3 Get job name
Determine-Job-Name
$global:job = Load-Job-From-File $env:SharedFolder $global:job $global:status.JobFileName

# Setup #4 change power options to ensure we don't shutdown part way through

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
    Write-Host "Importing scheduled task from $env:ComputerFurnisherScheduledTaskPath, this is responsible for running computer furnisher once the computer has rebooted. Please enter DA credentials to run task as"
    Start-Sleep -s 1 # Get users attention
    $creds = Get-Credential
    schtasks /Create /XML $env:ComputerFurnisherScheduledTaskPath /RU $creds.UserName /RP $creds.GetNetworkCredential().Password /TN "Computer Furnisher"
}

# Run #1 - User warning

Write-host -ForegroundColor DarkGreen "=========================* Computer Furnisher - Execution *============================="

Display-Warning

# Run #2 - Update number of executions
$global:status.NumberOfExecutions = $global:status.NumberOfExecutions + 1
Check-If-Wants-To-Reset-Number-Of-Executions

# Run #3 validation and tasks
Run-Validation
Run-Tasks

# Cleanup #1 

C:\Windows\system32\powercfg.exe -change -standby-timeout-ac 15
C:\Windows\system32\powercfg.exe -change -hibernate-timeout-ac 30

# Cleanup #2 - If this is the last execution then cleanup

Write-Host "Computer furnisher has been run " $global:status.NumberOfExecutions " times."
Upsert-File-From-Object $global:status "$logFolder/$env:StatusFileName"

Cleanup-When-Required

Write-Host "Power options have been reset. If running from a scheduled task, it will restart in 4 mintues..."


Write-host -ForegroundColor DarkGreen "=========================* Computer Furnisher - Done *============================="