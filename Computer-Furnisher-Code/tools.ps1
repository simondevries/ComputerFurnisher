
Function Validate-Path-Exists([string] $path, [string] $errorFolderName) {
    if ([string]::IsNullOrEmpty($path)) {
        Write-Host("Please specify a $errorFolderName path")
        EXIT
    }
    $pathExists = Test-Path $path
    if ($pathExists -eq $FALSE){
        throw [System.IO.FileNotFoundException] "Could not find $errorFolderName at path '$path'"
    }
}

Function Create-Folder-If-Does-Not-Exist([string] $path) {
    Write-Host $path
    New-Item -Path $path -ItemType "Directory" -Force | Out-Null
}

Function Delete-Folder-And-Content-If-Exists([string] $path){
    if($path.StartsWith($env:SharedDrive) -eq $True){
        throw "Deleting folders from network shared drive disabled for safety"
        return
    }

    $pathExists = Test-Path $path
    Write-host "Path Exists"
    if ($pathExists) {
        Write-Host "Removing item at path: $path"
        Remove-Item $path -force -recurse
    }
}



Function Get-File-From-Either-Location([string] $86bitPath, [string] $32bitPath){
    
    #todo sdv Make this smarter by actually checking the computers architecture
    $x86pathExists = Test-Path $86bitPath
    $x32pathExists = Test-Path $32bitPath

    if ($x86pathExists) {
        return $86bitPath
    } elseif ($x32pathExists) {
        return $32bitPath
    } else {
        #todo sdv throw?
        Write-Host "Could not find MS Office on this computer"
        return ""
    }
}

Function Set-Wallpaper()
{
    Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $value
   
    rundll32.exe user32.dll, UpdatePerUserSystemParameters 1, True  
}