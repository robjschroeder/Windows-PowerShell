$pathToExecutable32 = 'C:\Program Files\TSS Tools\kcssetup.exe'
$pathToExecutable64 = 'C:\Program Files (x86)\TSS Tools\kcssetup.exe'
$computername = Read-Host Please enter the name of the computer to run the process on

If (Test-Connection -ComputerName $computername -Count 1 -Quiet)
    {
        $architecture = (Get-WmiObject -ComputerName $computername -Class win32_operatingsystem).osarchitecture
        If($architecture -eq "32-bit")
            {
                $proc = Invoke-WmiMethod -ComputerName $computername -Class Win32_Process -Name Create -ArgumentList "$pathToExecutable32"
                # Register-WmiEvent -ComputerName $computername -Query "Select * from Win32_ProcessStopTrace Where ProcessID=$($proc.ProcessId)" -Action { Write-Host "Process ExitCode: $($event.SourceEventArgs.NewEvent.ExitStatus)" }
            }
        Else
            {
                $proc = Invoke-WmiMethod -ComputerName $computername -Class Win32_Process -Name Create -ArgumentList "$pathToExecutable64"
                # Register-WmiEvent -ComputerName $computername -Query "Select * from Win32_ProcessStopTrace Where ProcessID=$($proc.ProcessId)" -Action { Write-Host "Process ExitCode: $($event.SourceEventArgs.NewEvent.ExitStatus)" }
            }
    }    
