Function Print-Config-Paths() {
    Write-Host -ForegroundColor DarkGreen "===Config==="

    Write-Host "Silent: $env:Silent"
    Write-Host "Shared Drive: $env:SharedDrive"
    Write-Host "Root Server Folder: $env:SharedFolder"
    Write-Host "Job Server Folder: $env:JobFolder"
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
    Write-Host -ForegroundColor DarkGreen "===Job Tasks==="

    foreach ($task in $global:Job.Tasks.Keys) {
        $taskValue = $global:Job.Tasks[$task]
        Write-Host "$task : $taskValue"
    }
    $UpdateWindows = $global:Job.Tasks.UpdateWindows

    Write-Host -ForegroundColor DarkGreen "===End Job Tasks==="
}