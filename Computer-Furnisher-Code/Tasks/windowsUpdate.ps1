Import-Module './tools.ps1'

$taskDefinition = [PSCustomObject]@{
    identifier="windowsUpdate";
    isRerunnable=$true;
    sequence=5;
}
$taskDefinition | Add-Member -Name 'ValidateFunction' -Type ScriptMethod -Value { WindowsUpdateValidation }
$taskDefinition | Add-Member -Name 'ExecuteFunction' -Type ScriptMethod -Value { WindowsUpdateExecution }
$global:tasks += $taskDefinition

Function WindowsUpdateValidation() {
    # Todo check if connected to the fastest office internet connection?
    # Maybe check if on cable and power?
}


Function WindowsUpdateExecution() {

    Write-Host "Performing windows update"

    Get-WUInstall -IgnoreUserInput -AutoReboot -AcceptAll -NotCategory "Language packs" 
    $status = $global:status
    $status.Tasks.WindowsUpdate.Status = "Success (rerunnable)"
    Write-Host "Windows Update complete"
}
