$taskDefinition = [PSCustomObject]@{
    identifier="addPrinters";
    isRerunnable=$false;
    sequence=1;
}
$taskDefinition | Add-Member -Name 'ValidateFunction' -Type ScriptMethod -Value {AddPrintersValidation}
$taskDefinition | Add-Member -Name 'ExecuteFunction' -Type ScriptMethod -Value {AddPrintersExecution}
$global:tasks += $taskDefinition

Function AddPrintersValidation(){
    $foundServer = Test-Connection -computerName $env:PrintServer -Quiet
    $a = $foundServer.GetType()
    
    if ($foundServer -eq $TRUE) {
        Write-Host "A connection was successfully made to the print server for adding printers"
        return
    }   
    throw "Add printer failed validation as a connection to $env:PrintServer could not be established"
}

Function AddPrintersExecution() {
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
