
'.\Tasks\*.ps1' | gci | Import-Module 

Function Run-Tasks {
    Write-Host -ForegroundColor DarkGreen "=== Running tasks ==="
    Foreach ($taskKey in $global:tasks.Keys) {
        $task = $global:tasks[$taskKey]
        if ($global:job.Tasks.ContainsKey($taskKey) -eq $FALSE) {
            Write-Host "There does not exist a job with identifier $taskKey"
            continue
        }
        if ($global:status.Tasks.ContainsKey($taskKey) -eq $FALSE) {
            Write-Host "Adding task $taskKey to status file as it is a recently added task"
            $global:status.Tasks[$taskKey] = @{Name=$taskKey; Status="New";Reason=""}
        }
        
        $doesTaskBelongToJob = $global:job.Tasks[$taskKey]
        if ($doesTaskBelongToJob -eq $FALSE){
            Write-Host "Skipping for $taskKey as it is not part of this job"
            continue
        }

        $currentStatus = $global:status.Tasks[$taskKey].Status
        if ($task.isRerunnable -eq $FALSE -and $currentStatus -ne "new"){
            Write-Host "Skipping $taskKey as it has already run"
            # todo sdv test
            continue
        }
        Run-Task $task.ValidateFunction $global:status.Tasks[$taskKey]
    }
    
    Write-Host -ForegroundColor DarkGreen "=== Done running tasks ==="
}


Function Run-Task ([object] $func, [object] $statusOfCurrentTask) {
    $taskName = $statusOfCurrentTask.Name
    $taskStatus = $statusOfCurrentTask.Status
 
    Write-Host "Running task $taskName"
    Try {
        $result = $func.Invoke()
        Write-Host "Successfully completed task: $taskName"
        if ($statusOfCurrentTask.Status -ne "Success (rerunnable)") {
            $statusOfCurrentTask.Status = "Success"
        }
        $statusOfCurrentTask.Reason = ""
    } Catch {
        Write-Host "An error occured when executing $taskName: $_"
        $statusOfCurrentTask.Status = "Error"
        $statusOfCurrentTask.Reason = "$_"
    }
    Upsert-File-From-Object $global:status "$logFolder/$env:StatusFileName"
}


Function Run-Validation {
    Write-Host -ForegroundColor DarkGreen "=== Running validation ==="
    Foreach ($taskKey in $global:tasks.Keys) {
        $task = $global:tasks[$taskKey]
        if ($global:job.Tasks.ContainsKey($taskKey) -eq $FALSE) {
            Write-Host "There does not exist a job with identifier $taskKey"
            continue
        }
        if ($global:status.Tasks.ContainsKey($taskKey) -eq $FALSE) {
            Write-Host "Adding task $taskKey to status file as it is a recently added task"
            $global:status.Tasks[$taskKey] = @{Name=$taskKey; Status="New";Reason=""}
        }
        
        $doesTaskBelongToJob = $global:job.Tasks[$taskKey]
        if ($doesTaskBelongToJob -eq $FALSE){
            Write-Host "Skipping validation for $taskKey as it is not part of this job"
            continue
        }

        $currentStatus = $global:status.Tasks[$taskKey].Status
        if ($task.isRerunnable -eq $FALSE -and $currentStatus -ne "new"){
            Write-Host "Skipping validation for $taskKey as it has already run"
            continue
        }
        Run-With-Retry $task.ValidateFunction $global:status.Tasks[$taskKey]
    }
    
    Write-Host -ForegroundColor DarkGreen "=== Finished running validation ==="
}

function Run-With-Retry ([Object] $func, [Object]$statusOfCurrentTask) {
    $taskName = $statusOfCurrentTask.Name
    $taskStatus = $statusOfCurrentTask.Status

    Write-Host "Validating task $taskName : $func"
    
    $cmdInput = $NULL
    
    do {
        $validationStatus = ""
        Try{
            $validationStatus = $func.Invoke()
            $taskStatus = "Passed Validation"
        } Catch {
            $statusOfCurrentTask.Reason = $_
            $statusOfCurrentTask.Status = "Failed Validation"
            Write-Host "Task $taskName failed with the following error: $_"
            if ($env:silent.ToLower() -eq "true"){
                $cmdInput = "S"
            } else {
                $cmdInput = Read-Host "Press enter to try again, press S to skip?"
            }
        }

        Upsert-File-From-Object $global:status "$logFolder/$env:StatusFileName"

    } while (($statusOfCurrentTask.Status -eq "failed validation" -and ($cmdInput -eq $NULL -or $cmdInput.ToLower() -ne 's')))
}
