Import-Module './tools.ps1'

$taskDefinition = [PSCustomObject]@{
    isRerunnable=$true;
}
$taskDefinition | Add-Member -Name 'ValidateFunction' -Type ScriptMethod -Value { Validation }
$taskDefinition | Add-Member -Name 'ExecuteFunction' -Type ScriptMethod -Value { Execution }
$global:tasks["UpdateDrivers"] = $taskDefinition


Function Validation() {
    $BLinfo = manage-bde -status
    # if bitlocker is on then 
    if(($BLinfo | FindStr "Fully Decrypted").length -eq 0) {
        $global:status.BitLockerStatus = "On"
        throw "Cannot update drivers as bitlocker is on, please suspend bitlocker"
    }
}

Function Execution() {
    #this issues dell cli is installed during the software installation step

    $path = Get-File-From-Either-Location "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
    if ($path -eq "") {
        throw "Could not find dell command exe 'dcu-cli.exe'. Please ensure it is installed on this computer."
    }

    $path = Get-File-From-Either-Location "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
    #/addToIgnoreList   
    Start-Process $path -Wait -NoNewWindow

    $status.Tasks.UpdateDrivers.Status = "Success (rerunnable)"
}