Function Print-Result([Object] $status){
    $activateOfficeStatus = $status.Tasks.ActivateOffice.Status



    Write-Host "=== Status after execution complete ==="
    Write-Host "ActivateOffice: $activateOfficeStatus"
    
}

Function Print-Job-Status([Object] $job) {
    $UpdateWindows = $job.Tasks.UpdateWindows
    $SoftwareInstall = $job.Tasks.SoftwareInstallation
    $UpdateDrivers = $job.Tasks.UpdateDrivers
    $AddPrinters = $job.Tasks.AddPrinters
    $SetupTeamViewer = $job.Tasks.SetupTeamViewer
    $ActivateOffice = $job.Tasks.ActivateOffice
    $AddDelProf = $job.Task.AddDelProf
    Write-Host "===Job settings==="
    Write-Host "UpdateWindows = $UpdateWindows"
    Write-Host "SoftwareInstall = $SoftwareInstall"
    Write-Host "UpdateDrivers = $UpdateDrivers"
    Write-Host "AddPrinters = $AddPrinters"
    Write-Host "SetupTeamViewer = $SetupTeamViewer"
    Write-Host "ActivateOffice = $ActivateOffice"
    Write-Host "AddDelProf = $AddDelProf"
    Write-Host "======"
}