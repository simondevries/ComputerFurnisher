$taskDefinition = [PSCustomObject]@{
    identifier = "copyFileToLocalDrive";
    isRerunnable=$false;
    sequence=1;
}
$taskDefinition | Add-Member -Name 'ValidateFunction' -Type ScriptMethod -Value {CopyToLocalDriveValidation}
$taskDefinition | Add-Member -Name 'ExecuteFunction' -Type ScriptMethod -Value {CopyToLocalDriveExecution}
$global:tasks += $taskDefinition

Function CopyToLocalDriveValidation {

}

Function CopyToLocalDriveExecution {
    Copy-Item "$env:LocalFolderExecutables\Delprof2\" -Destination "$env:LocalDrive/Delprof2" -Recurse
    Copy-Item "$env:LocalFolderScheduledTasks\MapNetworkDrives\" -Destination "$env:LocalDrive/MapNetworkDrives" -Recurse
}
