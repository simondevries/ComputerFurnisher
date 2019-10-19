Import-Module './tools.ps1'

$taskDefinition = [PSCustomObject]@{
    isRerunnable=$true;
}
$taskDefinition | Add-Member -Name 'ValidateFunction' -Type ScriptMethod -Value {Validation}
$taskDefinition | Add-Member -Name 'ExecuteFunction' -Type ScriptMethod -Value {Execution}
$global:tasks["WindowsUpdate"] = $taskDefinition

Function Validation([Object] $status) {
    # Todo check if connected to the fastest office internet connection?
    # Maybe check if on cable and power?
}


Function Execution(){
    Get-WUInstall -IgnoreUserInput -AutoReboot -AcceptAll -NotCategory "Language packs" 

    $global:status.Tasks.UpdateWindows.Status = "Success (rerunnable)"
    Write-Host "Windows Update complete"
}
