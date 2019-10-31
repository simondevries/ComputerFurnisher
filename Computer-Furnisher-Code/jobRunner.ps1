
'.\Tasks\*.ps1' | gci | Import-Module 

Function Run-Tasks {
    Sort-Tasks

    Write-Host -ForegroundColor DarkGreen "=== Running tasks ==="
    Foreach ($task in $global:tasks) {
        $taskName = $task.Identifier
        if ($global:job.Tasks.ContainsKey($taskName) -eq $FALSE) {
            Write-Host "There does not exist a job with identifier $taskName"
            continue
        }
        if ($global:status.Tasks.ContainsKey($taskName) -eq $FALSE) {
            Write-Host "Adding task $taskName to status file as it is a recently added task"
            $global:status.Tasks[$taskName] = @{Name=$taskName; Status="New";Reason=""}
        }
        
        $doesTaskBelongToJob = $global:job.Tasks[$taskName]
        if ($doesTaskBelongToJob -eq $FALSE){
            Write-Host "Skipping $taskName as it is not part of this job"
            continue
        }

        $currentStatus = $global:status.Tasks[$taskName].Status
        if ($task.isRerunnable -eq $FALSE -and $currentStatus -ne "new"){
            Write-Host "Skipping $taskName as it has already run"
            # todo sdv test
            continue
        }
        Run-Task $task.ExecuteFunction $global:status.Tasks[$taskName]
    }
    
    Write-Host -ForegroundColor DarkGreen "=== Done running tasks ==="
}


Function Run-Task ([object] $func, [object] $statusOfCurrentTask) {
    $taskName = $statusOfCurrentTask.Name
    $taskStatus = $statusOfCurrentTask.Status
 
    Write-Host "Running task $taskName"
    Try {
        if ($global:useStubs -eq $FALSE) {
            $result = $func.Invoke()
        }        
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
    Sort-Tasks

    Write-Host -ForegroundColor DarkGreen "=== Running tasks ==="
    Foreach ($task in $global:tasks) {
        $taskName = $task.Identifier
        $task = $global:tasks[$taskName]
        if ($global:job.Tasks.ContainsKey($taskName) -eq $FALSE) {
            Write-Host "There does not exist a job with identifier $taskName"
            continue
        }
        if ($global:status.Tasks.ContainsKey($taskName) -eq $FALSE) {
            Write-Host "Adding task $taskName to status file as it is a recently added task"
            $global:status.Tasks[$taskName] = @{Name=$taskName; Status="New";Reason=""}
        }
        
        $doesTaskBelongToJob = $global:job.Tasks[$taskName]
        if ($doesTaskBelongToJob -eq $FALSE){
            Write-Host "Skipping validation for $taskName as it is not part of this job"
            continue
        }

        $currentStatus = $global:status.Tasks[$taskName].Status
        if ($task.isRerunnable -eq $FALSE -and $currentStatus -ne "new"){
            Write-Host "Skipping validation for $taskName as it has already run"
            continue
        }
        Run-With-Retry $task.ValidateFunction $global:status.Tasks[$taskName]
    }
    
    Write-Host -ForegroundColor DarkGreen "=== Finished running validation ==="
}

function Run-With-Retry ([Object] $func, [Object]$statusOfCurrentTask) {
    $taskName = $statusOfCurrentTask.Name
    $taskStatus = $statusOfCurrentTask.Status

    Write-Host "Validating task $taskName"
    
    $cmdInput = $NULL
    
    do {
        $validationStatus = ""
        Try {
                if ($global:useStubs -eq $FALSE) {
                    $validationStatus = $func.Invoke()
                }
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

function Sort-Tasks () {
    $global:tasks | sort-object -property sequence
}