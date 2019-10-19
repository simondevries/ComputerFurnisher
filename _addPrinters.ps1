Function Add-Printer-Run-Validation([Object] $status){
    $foundServer = Test-Connection -computerName $env:PrintServer -Quiet
    $a = $foundServer.GetType()
    
    if ($foundServer -eq $TRUE) {
        Write-Host "A connection was successfully made to the print server for adding printers"
        return
    }   
    throw "Add printer failed validation as a connection to $env:PrintServer could not be established"
}

Function Add-Printers([Object] $status, [Object] $printersToAdd) {
    #todo What printers to add?
# This function maps printers from an array
    # Loop over the array
    Write-Host "Printers to add $printersToAdd"


    foreach ($printer in $printersToAdd) {
        Try {
            Write-Host "Adding printer $printer"
            (New-Object -ComObject WScript.Network).AddWindowsPrinterConnection($printer)
            $status.SuccessfulPrinterInstalls += $printer
        } Catch {
            $status.UnsuccessfulPrinterInstalls += $printer
        }
    }
}
