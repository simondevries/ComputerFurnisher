Function Software-Installation-Run-Validation([Object] $status, [String[]] $softwareToInstall) {
    #todo sdv this is not very accurate
    # $softwareFromFolders = Get-ChildItem -Path $pathToSoftwareInstallers
    # foreach ($softwareFromJob in $softwareToInstall) {
    #     $installerExists = Test-Path "$pathToSoftwareInstallers/$softwareFromJob/install.bat" -PathType Leaf
    #     if ($installerExists -eq $TRUE) {
    #         # todo
    #     }else{
    #         write-host "Could not find software $softwareFromJob in software path. Please ensure the folder exists and a install.bat file exists."
    #         $softwareToInstall = $softwareToInstall | Where-Object { $_ -ne $softwareFromJob }
    #     }
    # }
    
    # foreach ($software in $softwareToInstall) {
    #     $hasSoftware = (gp HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -Like "*$software*"
    #     if ($hasSoftware -eq $TRUE) {
    #         Write-Host "An installation file was found for $software and it is scheduled to be updated"
    #     } else {
    #         Write-Host "An installation file was found for $software and it is scheduled to be installed"
    #     }
    # }

    $status.SoftwareToInstall = $softwareToInstall
    # $status.Tasks.SoftwareInstallation.Status = "Passed Validation"
}

##############################

Function Software-Installation([object] $status) {
    Write-Host "Installing Software..."
    
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