
# Possible status New, Failed Validation & Skipped, Passed Validation, Failed Validation, Error, Success, Already Completed
$global:status = @{
    #todo Better way to initialize array?
    Tasks = @{
        UpdateWindows = @{Name="Update Windows"; Status = "New";Reason = ""};
        SoftwareInstallation = @{Name="Software Installation"; Status = "New";Reason = ""};
        UpdateDrivers = @{Name="Update Drivers"; Status = "New";Reason = ""};
        AddPrinters = @{Name="Add Printers"; Status = "New";Reason = ""}
        ActivateOffice = @{Name="Activate Office"; Status = "New";Reason = ""};
        AddDelProf = @{ Name="Add DelProf"; Status = "New";Reason = "" };
        SetupTeamViewer = @{ Name="Setup TeamViewer"; Status = "New";Reason = "" };
    };
    OfficeActivationStatus = "Not Checked";
    WindowsUpdates = @();
    NumberOfExecutions = 0
    SuccessfulPrinterInstalls = @();
    UnsuccessfulPrinterInstalls = @();
    SoftwareToInstall = @();
    SuccessfulSoftwareInstalls=@();
    UnsuccessfulSoftwareInstalls=@();
    BitLockerStatus = "Unknown";
    HasAcceptedWarning=$FALSE;
    LastExecution="Never";
    JobFileName="job"
}