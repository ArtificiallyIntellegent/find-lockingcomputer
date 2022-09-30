<#
.Synopsis
   Finds Computers locking AD Accounts
.DESCRIPTION
   Script queries all registered Domain Controllers, looks for Lockout Entries and extract Computer names that are locking up the AD Account.
.EXAMPLE
   Find-LockingComputer.ps1 -username mjake
.INPUTS
   AD Username
.OUTPUTS
   User    LoggedOn        DC           Timestamp
   ----    --------        --           ---------
   mjake   CA-Win-1        LA-DC02      7/01/2022 8:38:11 AM
.NOTES
  Version:        1.0
  Author:         Asif Punjwani
  Creation Date:  Fri 30 Sep 2022 06:20:50 PM CDT

#>

[CmdletBinding()]
[Alias()]
[OutputType([int])]
Param
(
    # Param1 help description
    [Parameter(
      Mandatory=$true,
      ValueFromPipelineByPropertyName=$true,
      Position=0)]
          $username

)

$payload={
    function Find-LockingComputer($DC, $username){
    
    $logs=Invoke-Command -ComputerName $DC -ScriptBlock{Get-EventLog -LogName "Security" -InstanceId 4740 -After (get-date).AddDays(-1) -ErrorAction SilentlyContinue|sort -Property Time| Select -last 1}
    $logs = $logs|?{$username -in $_.ReplacementStrings}
    
    if($logs.EventID.count -gt 0){
        
        $OBJ=[pscustomobject]@{
        User = $username
        DC = $DC
        LoggedOn=$logs.ReplacementStrings[1]
        Timestamp=$logs[0].TimeGenerated               
        }
        
        return $OBJ
            }
    
}
}

$DC_List = (Get-ADDomainController -Filter *).Name

$collection=@()

foreach($DC in $DC_List){
    $output=Start-Job -ScriptBlock{Find-LockingComputer -DC $using:DC -username $using:username} -InitializationScript $payload
}

do{
    $JobCount = Get-Job | Measure-Object | select -ExpandProperty Count
    $completed = Get-Job -State Completed  | Measure-Object | select -ExpandProperty Count
}while($completed -lt $JobCount)

$jobs=Get-Job | Receive-Job| Select User, LoggedOn, DC, Timestamp

Get-job | Stop-Job
Get-Job | Remove-Job

return $jobs
