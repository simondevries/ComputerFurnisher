$taskDefinition = [PSCustomObject]@{
    isRerunnable=$false;
}
$taskDefinition | Add-Member -Name 'ValidateFunction' -Type ScriptMethod -Value {Validation}
$taskDefinition | Add-Member -Name 'ExecuteFunction' -Type ScriptMethod -Value {Execution}
$global:tasks["CopyFilesToLocalDrive"] = $taskDefinition

Function Validation {

}

Function Execution {
    Copy-Item "$env:LocalFolderExecutables\Delprof2\" -Destination "$env:LocalDrive/Delprof2" -Recurse
    Copy-Item "$env:LocalFolderScheduledTasks\MapNetworkDrives\" -Destination "$env:LocalDrive/MapNetworkDrives" -Recurse
}
