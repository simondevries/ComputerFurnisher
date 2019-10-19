Function Print-Config-Paths() {
    Write-Host -ForegroundColor DarkGreen "===Config==="

    Write-Host "Silent: $env:Silent"
    Write-Host "Shared Drive: $env:SharedDrive"
    Write-Host "Root Server Folder: $env:SharedFolder"
    Write-Host "Software Install folder: $env:SoftwareFolder"
    Write-Host "Local Folder: $env:LocalFolderPath"
    Write-Host "Local Temp Software Folder: $env:LocalFolderPath"
    Write-Host "Print Server: $env:PrintServer"
    Write-Host "Server Software Folder: $env:SoftwareFolder"
    
    Write-Host -ForegroundColor DarkGreen "===End Config==="
}

Function Print-Current-Status() {
    $status = $global:status
    $jobName = $status.JobFileName
    $numberOfExecutions = $status.NumberOfExecutions
    $softwareToInstall = $status.SoftwareToInstall
    $successfulSoftwareInstalls = $status.$successfulSoftwareInstalls
    $unsuccessfulSoftwareInstalls = $status.$unsuccessfulSoftwareInstalls
    $lastExecution = $status.$lastExecution

    Write-Host -ForegroundColor DarkGreen "===Status==="
    
    Write-Host "Job name: $jobName"
    Write-Host "Number of executions: $numberOfExecutions"
    Write-Host "Software yet to install: $softwareToInstall"
    Write-Host "Successful software installs: $successfulSoftwareInstalls"
    Write-Host "Unsuccessful software installs: $unsuccessfulSoftwareInstalls"
    Write-Host "Last Execution: $lastExecution"
    Write-Host -ForegroundColor DarkGreen "===End Status==="
}

Function Print-Job-Status() {
    $UpdateWindows = $global:Job.Tasks.UpdateWindows
    $SoftwareInstall = $global:Job.Tasks.SoftwareInstallation
    $UpdateDrivers = $global:Job.Tasks.UpdateDrivers
    $AddPrinters = $global:Job.Tasks.AddPrinters
    $SetupTeamViewer = $global:Job.Tasks.SetupTeamViewer
    $ActivateOffice = $global:Job.Tasks.ActivateOffice
    $AddDelProf = $global.Status.Task.AddDelProf
    Write-Host -ForegroundColor DarkGreen "===Job Settings==="
    Write-Host "UpdateWindows: $UpdateWindows"
    Write-Host "SoftwareInstall: $SoftwareInstall"
    Write-Host "UpdateDrivers: $UpdateDrivers"
    Write-Host "AddPrinters: $AddPrinters"
    Write-Host "SetupTeamViewer: $SetupTeamViewer"
    Write-Host "ActivateOffice: $ActivateOffice"
    Write-Host "AddDelProf: $AddDelProf"
    Write-Host -ForegroundColor DarkGreen "===End Job Settings==="
}