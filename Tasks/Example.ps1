
$taskDefinition = [PSCustomObject]@{
    isRerunnable=$false;
}
$taskDefinition | Add-Member -Name 'ValidateFunction' -Type ScriptMethod -Value {Validation}
$taskDefinition | Add-Member -Name 'ExecuteFunction' -Type ScriptMethod -Value {Execution}
$global:tasks["Example"] = $taskDefinition


Function Validation() {

}

Function Execution() {

}





