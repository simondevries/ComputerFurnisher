$taskDefinition = [PSCustomObject]@{
    identifier="SoftwareInstallation";
    isRerunnable=$false;
    sequence=1;
}
$taskDefinition | Add-Member -Name 'ValidateFunction' -Type ScriptMethod -Value {CopyToLocalDriveValidation}
$taskDefinition | Add-Member -Name 'ExecuteFunction' -Type ScriptMethod -Value {CopyToLocalDriveExecution}
$global:tasks += $taskDefinition


Function CopyToLocalDriveValidation() {
    $global:status.SoftwareToInstall = $global:job.SoftwareToInstall
    # $status.Tasks.SoftwareInstallation.Status = "Passed Validation"
}

##############################

Function CopyToLocalDriveExecution() {
    Write-Host "Installing Software..."
    $status = $global:status

    foreach ($softwareToInstall in $status.SoftwareToInstall) {
        Install-Specified-Software $status $softwareToInstall
    }

    $status.Tasks.UpdateDrivers.Status = "Success (rerunnable)"
    Write-Host "Software Install complete!"
}

Function Install-Specified-Software([object] $status, [string] $softwareToInstall) {
    $softwareBatInstallationPath = "$env:SoftwareFolder/$softwareToInstall/install.bat"
    $softwareFolderPath = "$env:SoftwareFolder/$softwareToInstall"
    
    $sortwareBatPathExists = Test-Path $softwareBatInstallationPath -PathType Leaf
    if ($sortwareBatPathExists -eq $FALSE){
        Write-Warning "Skipping installation for $softwareToInstall as the install.bat file could not be found"
        $status.UnsuccessfulSoftwareInstalls += $softwareToInstall    
        return
    }

    Write-Host "Installing $softwareToInstall."
    # $b = $env:LocalFolderTempSoftware/$softwareToInstall
    Write-Host "Copying from $softwareFolderPath to local driver $b"
    
    if ((Test-Path "$env:LocalFolderTempSoftware/$softwareToInstall") -eq $FALSE) {
        Copy-Item $softwareFolderPath -Destination "$env:LocalFolderTempSoftware/$softwareToInstall" -Recurse
    }
    $path = "$env:LocalFolderTempSoftware/$softwareToInstall/install.bat"
    $workingDirectory = "$env:LocalFolderTempSoftware/$softwareToInstall"
    Write-Host "Running install.bat at path $path at directory $workingDirectory"
    $result = Start-Process $path -Wait -WorkingDirectory $workingDirectory -NoNewWindow

    #todo sdv exit code does not work here

    if($result.ExitCode -eq -1) {
        $status.UnsuccessfulSoftwareInstalls += $softwareToInstall    
        throw "Failed to install"
    }

    $status.SuccessfulSoftwareInstalls += $softwareToInstall
    Write-Host "Successfull installed $softwareToInstall"
}