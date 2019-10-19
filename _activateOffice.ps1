Function Get-Path-To-Office {
    
    $x86pathExists = Test-Path "C:\Program Files (x86)\Microsoft Office\Office16\ospp.vbs"
    $x32pathExists = Test-Path "C:\Program Files\Microsoft Office\Office16\ospp.vbs"

    if ($x86pathExists) {
        return "C:\Program Files (x86)\Microsoft Office\Office16\ospp.vbs"
    } elseif ($x32pathExists) {
        return "C:\Program Files\Microsoft Office\Office16\ospp.vbs"
    } else {
        Write-Host "Could not find MS Office on this computer"
        $status.OfficeActivationStatus = "Could not find office on this computer"
        return ""
    }
}

Function Update-Office-Run-Validation ([Object] $status) {
    Write-Host "Checking if Office is activated..."

    $officePath = Get-Path-To-Office
    if($officePath -eq "") {
        throw "Failed to get path to office"
    }
    $result = cscript $officePath /dstatus
    # todo change to key word
    if ($result -match "---LICENSED---"){
        Write-Host "Office is already activated"
        $status.OfficeActivationStatus = "Activated"
    } else {
        Write-Host "Office is not activated. An attempt will be made to update it"
        $status.OfficeActivationStatus = "Not Activated"
    }
}

Function Activate-Office([Object] $status) {
    #todo what is the expected magic string here?
    
    if ($status.OfficeActivationStatus -eq "Activated") {
        Write-Host "Office is already activated. Skipping activation step"
        return 
    }

    $officePath = Get-Path-To-Office
    if($officePath -eq "") {
        throw "Office could not be found on this computer"
    }
    
    $result = cscript $officePath /inpkey:$env:OfficeKey
    # result is a string array, so -like will not work here
    if (-not ($result -match "<Product key installation successful>")) {
        $status.OfficeActivationStatus = "Not Activated"
        throw "Failed to activate office, check the input key"
    }

    $result = cscript $officePath /act
    
    if (-not ($result -match "<Product activation successful>")) {
        $status.OfficeActivationStatus = "Not Activated"
        throw "Failed to activate office, however the input key appeared to be correct."
    }

    Write-Host "Office was successfully activated"
    $status.OfficeActivationStatus = "Activated"
 }