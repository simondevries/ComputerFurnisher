Import-Module -name "./tools.ps1" -force

#If status file does not exist then it will use the default status
Function Load-Status-From-File([string] $path, [Object] $defaultStatus) {
    $pathExists = Test-Path "$path/$env:StatusFileName" -PathType Leaf
    if ($pathExists -eq $FALSE){
        Write-Host "Status file does not exist at path $path... creating"
        Upsert-File-From-Object $defaultStatus "$path/$env:StatusFileName"
        return $defaultStatus
    }
    $a = Import-Clixml "$path/$env:StatusFileName"
    return $a
}

Function Load-Job-From-File([string] $path, [Object] $defaultJob, [String] $jobFileName) {
    $pathExists = Test-Path "$path/$jobFileName" -PathType Leaf
    if ($pathExists -eq $FALSE){
        Write-Host "Job file does not exist at path $path... creating"
        Upsert-File-From-Object $defaultJob "$path/$jobFileName"
        return $defaultJob
    } 

    return Import-Clixml "$path/$jobFileName"
}

Function Upsert-File-From-Object([Object] $status, [string] $path) {
    $status | Export-Clixml $path
}

Function Delete-File([string] $path) {
    Remove-Item -Path $path
}
