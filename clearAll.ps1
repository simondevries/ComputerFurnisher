
Import-Module -name './tools.ps1' -force

$computerName = $env:computername
Write-Host "ComputerName $computerName"
$statusPath="$env:LogFolder/$computerName/$env:StatusFileName"

New-PSDrive -Name $env:SharedDriveLetter -PSProvider "FileSystem" -Root $env:SharedDriveAddress

$pathExists = Test-Path $statusPath -PathType Leaf
if ($pathExists -eq $TRUE) {
    Write-Host "Delting path $statusPath"
    Remove-Item -Path "$statusPath"
} else {
    write-host "Path $statusPath doesn't exist"
}

Delete-Folder-And-Content-If-Exists $env:LocalFolderTempSoftware
Delete-Folder-And-Content-If-Exists $env:LocalFolderPath
