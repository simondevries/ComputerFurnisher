
$taskDefinition = [PSCustomObject]@{
    identifier="example"
    isRerunnable=$false;
    sequence=1;
}
$taskDefinition | Add-Member -Name 'ValidateFunction' -Type ScriptMethod -Value {CopyToLocalDriveValidation}
$taskDefinition | Add-Member -Name 'ExecuteFunction' -Type ScriptMethod -Value {CopyToLocalDriveExecution}
$global:tasks += $taskDefinition


Function CopyToLocalDriveValidation() {

}

Function CopyToLocalDriveExecution() {

}





