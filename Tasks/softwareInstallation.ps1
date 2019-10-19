$taskDefinition = [PSCustomObject]@{
    isRerunnable=$false;
}
$taskDefinition | Add-Member -Name 'ValidateFunction' -Type ScriptMethod -Value {Validation}
$taskDefinition | Add-Member -Name 'ExecuteFunction' -Type ScriptMethod -Value {Execution}
$global:tasks["SoftwareInstallation"] = $taskDefinition


Function Validation([Object] $status, [String[]] $softwareToInstall) {
    $status.SoftwareToInstall = $global:job.SoftwareToInstall
    # $status.Tasks.SoftwareInstallation.Status = "Passed Validation"
}

##############################

Function Execution() {
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
    $softwareFolderPath = "$path/$softwareToInstall"
    
    $sortwareBatPathExists = Test-Path $softwareBatInstallationPath -PathType Leaf
    if ($sortwareBatPathExists -eq $FALSE){
        Write-Warning "Skipping installation for $softwareToInstall as the install.bat file could not be found"
        $status.UnsuccessfulSoftwareInstalls += $softwareToInstall    
        return
    }

    Write-Host "Installing $softwareToInstall at path $softwareBatInstallationPath"
    
    if ((Test-Path "$env:LocalFolderTempSoftware/$softwareToInstall") -eq $FALSE) {
        Write-Host "Copying from $softwareFolderPath to local driver"
        Copy-Item $softwareFolderPath -Destination "$env:LocalFolderTempSoftware/$softwareToInstall" -Recurse
    }
    
    Write-Host "Running install.bat"
    $result = Start-Process "$env:LocalFolderTempSoftware/$softwareToInstall/install.bat" -Wait -WorkingDirectory "$env:LocalFolderTempSoftware/$softwareToInstall" -NoNewWindow

    #todo sdv exit code does not work here

    if($result.ExitCode -eq -1) {
        $status.UnsuccessfulSoftwareInstalls += $softwareToInstall    
        throw "Failed to install"
    }

    $status.SuccessfulSoftwareInstalls += $softwareToInstall
    Write-Host "Successfull installed $softwareToInstall"
}