Import-Module './tools.ps1'

Function Update-Drivers-Run-Validation([Object] $status) {
    $BLinfo = manage-bde -status
    # if bitlocker is on then 
    if(($BLinfo | FindStr "Fully Decrypted").length -eq 0) {
        $status.BitLockerStatus = "On"
        throw "Cannot update drivers as bitlocker is on, please suspend bitlocker"
    }


}


Function Update-Drivers([Object] $status) {

    $path = Get-File-From-Either-Location "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
    if ($path -eq "") {
        throw "Could not find dell command exe 'dcu-cli.exe'. Please ensure it is installed on this computer."
    }

    $path = Get-File-From-Either-Location "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
    #/addToIgnoreList   
    Start-Process $path -Wait -NoNewWindow

    $status.Tasks.UpdateDrivers.Status = "Success (rerunnable)"
}
