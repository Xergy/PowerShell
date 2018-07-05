
$TimeStart = Get-Date
$TimeEnd = "23:52:00"


function LogCleanUp{
$RemoveLogAfterDays = "0"
$Extension = "*.csv"
$LastWrite = $TimeStart.AddDays(-$RemoveLogAfterDays)
$LogFileFolder = "C:\Files\Pinglog" 
$Files = Get-Childitem $LogFileFolder -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}

foreach ($File in $Files) 
    {
    if ($File -ne $NULL)
        {
        write-host "Deleting File $File" 
        Remove-Item $File.FullName | out-null
        }
    else
        {
        Write-Host "No more files to delete!"
        }
    }
}

workflow PingTest { 
    $TargetComputers = @("ams-ilm","ams-web","bad-sql")
    
    Foreach ($Computer in $TargetComputers){
        $SourceComputer = "ams-lim"    
        $Time = Get-Date
        $TestResult = Test-Connection -ComputerName $Computer -Count 1 -ErrorAction SilentlyContinue
        inlinescript{
            if ($using:TestResult.ResponseTime -eq $null){
                $ResponseTime = -1
            } else {
                $ResponseTime = $using:TestResult.ResponseTime
            }
            $ResultObject = New-Object PSObject -Property @{Time = $using:Time; Source = $using:SourceComputer ;Target = $using:Computer; ResponseTime = $ResponseTime}
            $TimeStartSortable = Get-Date -format "yyyyMMdd" 
            $Logfile = "C:\Files\Pinglog\PingLog_" + $SourceComputer + "_" + $TimeStartSortable + ".csv" 
            Export-Csv -InputObject $ResultObject $Logfile -Append
        }
    }
}

Clear-Host
Write-Host "Start Time: $Logfile"
Write-Host "Start Time: $TimeStart"
write-host "End Time:   $TimeEnd"

LogCleanUp

Do { 
 $TimeNow = Get-Date
 if ($TimeNow -ge $TimeEnd) {
  Write-host "All done for the Day!"
 } else {
  Write-Host "Not done yet, it's only $TimeNow"
  Write-Host $TimeNow "Testing..." 
  PingTest
  Write-Host "Sleeping..."
  Start-Sleep -Seconds 30
 }
}
Until ($TimeNow -ge $TimeEnd)
