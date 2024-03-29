Import-Module -name "./tools.ps1" -force

# Status file contains a log of what tasks have successfully run
# If status file does not exist then it will use the default status
Function Load-Status-From-File([string] $path, [Object] $defaultStatus) {
    $pathExists = Test-Path "$path/$env:StatusFileName" -PathType Leaf
    if ($pathExists -eq $FALSE){
        Write-Host "Status file does not exist at path $path... creating"
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Upsert-File-From-Object $defaultStatus "$path/$env:StatusFileName"
        return $defaultStatus
    }
    $a = Import-Clixml "$path/$env:StatusFileName"
    return $a
}

Function Load-Job-From-File([string] $path, [String] $jobFileName) {
    $pathExists = Test-Path "$path/$jobFileName" -PathType Leaf
    if ($pathExists -eq $FALSE){
       throw "Could not find a job at path $path"
    } 

    return Import-Clixml "$path/$jobFileName"
}

Function Upsert-File-From-Object([Object] $status, [string] $path) {
    $status | Export-Clixml $path
}

Function Delete-File([string] $path) {
    Remove-Item -Path $path
}
