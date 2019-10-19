Function Add-DelProf-Validation {

}

Function Add-DelProf {
    Copy-Item "$env:LocalFolderExecutables\Delprof2\" -Destination "$env:LocalDrive/Delprof2" -Recurse
    Copy-Item "$env:LocalFolderScheduledTasks\MapNetworkDrives\" -Destination "$env:LocalDrive/MapNetworkDrives" -Recurse
}
