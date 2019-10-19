
Import-Module -name './tools.ps1' -force

$logFolderForThisComputer = "$env:LogFolder\$env:computername"
$statusPath="$env:LogFolder/$env:StatusFileName"

New-PSDrive -Name $env:SharedDriveLetter -PSProvider "FileSystem" -Root $env:SharedDriveAddress

$pathExists = Test-Path $statusPath -PathType Leaf
if ($pathExists -eq $TRUE) {
    Write-Host "Deleting the old status file as shouldClearStatus was set to true"
    Write-Host "Delting path $statusPath"
    Remove-Item -Path "$logFolderForThisComputer/$env:StatusFileName"
}else{
    write-host "Path $statusPath doesn't exist"
}

$pathExists = Test-Path $env:LocalFolderTempSoftware
if ($pathExists -eq $TRUE) {
    Write-Host "Deleting temp software from the d drive"
    Write-Host "Delting path $env:LocalFolderTempSoftware"
    Remove-Item -Path $env:LocalFolderTempSoftware -recurse -force
} else {
    write-host "Path $env:LocalFolderTempSoftware doesn't exist and so was not cleared"
}


Delete-Folder-And-Content-If-Exists $env:LocalFolderPath
Delete-Folder-And-Content-If-Exists $env:LocalFolderTempSoftware
