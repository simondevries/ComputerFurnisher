Import-Module './tools.ps1'

Function Windows-Update-Run-Validation([Object] $status) {
    # todo Doesn't work in windows 7
    # $result = $NULL
    # $netadapter = Get-NetAdapter | Where-Object PhysicalMediaType -EQ 802.3 # $connectionName.ToLower() -contains "*afm-personal*" -and
    # if ($netadapter -eq "Connected") {
    # # if ($netadapter.Status -eq "Disconnected") {
    #     Write-Host "Cannot update windows when user is not connected to the internet"
    #     throw "Could not establish ethernet connection"
    # }

#Maybe check if on cable and power?

#    Write-Host "Checking for Windows Updates..."
#   Get-WUList -NotCategory "Language packs" 
#    foreach ($update in $listOfUpdates){
#        $updateTitle = $update.Title
#        $status.WindowsUpdates += $update.Title
#        Write-Host "Found update: $updateTitle"  
#    }
}


Function Update-Windows([Object] $status, [string] $path){
    # I think we need to ignore language packs
    # todo check error code
    Get-WUInstall -IgnoreUserInput -AutoReboot -AcceptAll -NotCategory "Language packs" 

    $status.Tasks.UpdateWindows.Status = "Success (rerunnable)"
    Write-Host "Windows Update complete"
}
