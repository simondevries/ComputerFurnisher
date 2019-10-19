$taskDefinition = [PSCustomObject]@{
    isRerunnable=$false;
}
$taskDefinition | Add-Member -Name 'ValidateFunction' -Type ScriptMethod -Value {Validation}
$taskDefinition | Add-Member -Name 'ExecuteFunction' -Type ScriptMethod -Value {Execution}
$global:tasks["AddPrinters"] = $taskDefinition

Function Validation(){
    $foundServer = Test-Connection -computerName $env:PrintServer -Quiet
    $a = $foundServer.GetType()
    
    if ($foundServer -eq $TRUE) {
        Write-Host "A connection was successfully made to the print server for adding printers"
        return
    }   
    throw "Add printer failed validation as a connection to $env:PrintServer could not be established"
}

Function Execution() {
    $printersToAdd = $global:job.PrintersToAdd
    Write-Host "Printers to add $printersToAdd"

    foreach ($printer in $printersToAdd) {
        Try {
            Write-Host "Adding printer $printer"
            (New-Object -ComObject WScript.Network).AddWindowsPrinterConnection($printer)
            $global:status.SuccessfulPrinterInstalls += $printer
        } Catch {
            $global:status.UnsuccessfulPrinterInstalls += $printer
        }
    }
}
