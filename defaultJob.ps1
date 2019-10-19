$global:job = @{
    Tasks = @{
        UpdateWindows = $TRUE;
        SoftwareInstallation = $TRUE;
        UpdateDrivers = $TRUE;
        AddPrinters = $TRUE;
        SetupTeamViewer = $TRUE;
        ActivateOffice = $TRUE;
        AddDelProf = $TRUE
    };
    SoftwareToInstall = @("Sublime Text", "Keepass");
    PrintersToAdd = @("\\SERVER\Printer")
}