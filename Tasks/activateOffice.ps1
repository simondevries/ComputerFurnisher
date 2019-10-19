$taskDefinition = [PSCustomObject]@{
    isRerunnable=$false;
}
$taskDefinition | Add-Member -Name 'ValidateFunction' -Type ScriptMethod -Value { Validation }
$taskDefinition | Add-Member -Name 'ExecuteFunction' -Type ScriptMethod -Value { Execution }
$global:tasks["ActivateOffice6"] = $taskDefinition

Function Validation () {
    Write-Host "Checking if Office is activated..."

    $officePath = Get-Path-To-Office
    if($officePath -eq "") {
        throw "Failed to get path to office"
    }
    $result = cscript $officePath /dstatus
    # todo change to key word
    if ($result -match "---LICENSED---"){
        Write-Host "Office is already activated"
        $global:status.OfficeActivationStatus = "Activated"
    } else {
        Write-Host "Office is not activated. An attempt will be made to update it"
        $global:status.OfficeActivationStatus = "Not Activated"
    }
}

Function Execution() {
    #todo what is the expected magic string here?
    
    if ($global:status.OfficeActivationStatus -eq "Activated") {
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
        $global:status.OfficeActivationStatus = "Not Activated"
        throw "Failed to activate office, check the input key"
    }

    $result = cscript $officePath /act
    
    if (-not ($result -match "<Product activation successful>")) {
        $global:status.OfficeActivationStatus = "Not Activated"
        throw "Failed to activate office, however the input key appeared to be correct."
    }

    Write-Host "Office was successfully activated"
    $global:status.OfficeActivationStatus = "Activated"
 }

 # Helpers
 

Function Get-Path-To-Office {
    
    $x86pathExists = Test-Path "C:\Program Files (x86)\Microsoft Office\Office16\ospp.vbs"
    $x32pathExists = Test-Path "C:\Program Files\Microsoft Office\Office16\ospp.vbs"

    if ($x86pathExists) {
        return "C:\Program Files (x86)\Microsoft Office\Office16\ospp.vbs"
    } elseif ($x32pathExists) {
        return "C:\Program Files\Microsoft Office\Office16\ospp.vbs"
    } else {
        Write-Host "Could not find MS Office on this computer"
        $global:status.OfficeActivationStatus = "Could not find office on this computer"
        return ""
    }
}