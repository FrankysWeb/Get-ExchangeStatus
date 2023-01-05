#Database Status
write-host "
--------------------------------------------------------------------------------
Database Status
--------------------------------------------------------------------------------
" -foregroundcolor yellow
$Databases = Get-MailboxDatabaseCopyStatus -Server $env:Computername
foreach ($Database in $Databases) {
	if ($Database.Status -eq "Mounted" -or $Database.Status -eq "Healthy") {
		write-host "Database" $Database.DatabaseName "on Server" $Database.Mailboxserver "is " -NoNewline
		write-host $Database.Status -ForegroundColor green
	}
	else {
		write-host "Database" $Database.DatabaseName "on Server" $Database.Mailboxserver "is " -NoNewline
		write-host $Database.Status -ForegroundColor red
	}
}

#Queue Status
write-host "
--------------------------------------------------------------------------------
Queue Status
--------------------------------------------------------------------------------
" -foregroundcolor yellow
$Queues = Get-Queue -Server $env:Computername
foreach ($Queue in $Queues) {
	if ($Queue.Status -eq "Ready") {
		write-host "Queue" $Queue.QueueIdentity.Type "on Server" $Queue.QueueIdentity.Server "is " -NoNewline
		write-host $Queue.Status -ForegroundColor green
	}
	else {
		write-host "Queue" $Queue.QueueIdentity.Type "on Server" $Queue.QueueIdentity.Server "is " -NoNewline
		write-host $Queue.Status -ForegroundColor red
	}
}

#Service Status
write-host "
--------------------------------------------------------------------------------
Service Status
--------------------------------------------------------------------------------
" -foregroundcolor yellow
$ExchangeServices = Get-Service -DisplayName "Microsoft Exchange*" | where {$_.StartType -eq "Automatic"}
foreach ($ExchangeService in $ExchangeServices) {
	if ($ExchangeService.Status -eq "Running") {
		write-host "Service" $ExchangeService.ServiceName "on Server" $env:Computername "is " -NoNewline
		write-host $ExchangeService.Status -ForegroundColor green
	}
	else {
		write-host "Service" $ExchangeService.ServiceName "on Server" $env:Computername "is " -NoNewline
		write-host $ExchangeService.Status -ForegroundColor red
	}		
}	
#Volume Status
write-host "
--------------------------------------------------------------------------------
Volume Status
--------------------------------------------------------------------------------
" -foregroundcolor yellow
$props = @(
    'DriveLetter'
    'FileSystemLabel'
    'FileSystem'
    'DriveType'
    'HealthStatus'
    'OperationalStatus'
    @{
        Name = 'SizeRemaining'
        Expression = { "{0:N3} Gb" -f ($_.SizeRemaining/ 1Gb) }
    }
    @{
        Name = 'Size'
        Expression = { "{0:N3} Gb" -f ($_.Size / 1Gb) }
    }
    @{
        Name = 'PercentFree'
        Expression = { "{0:P}" -f ($_.SizeRemaining / $_.Size) }
    }
)

$Volumes = Get-Volume | Select-Object $props | where {$_.Size -gt 1GB}
foreach ($Volume in $Volumes) {
	if ($Volume.FileSystem -eq "NTFS" -or $Volume.FileSystem -eq "ReFS" -and $Volume.HealthStatus -eq "Healthy" -and $Volume.PercentFree -gt 10) {
		write-host "Volume" $Volume.Driveletter $Volume.FileSystemLabel "on Server" $env:Computername "is " -NoNewline
		write-host $Volume.HealthStatus -ForegroundColor green -NoNewline
		write-host " with " -NoNewline
		write-host $Volume.PercentFree -ForegroundColor green -NoNewline
		write-host " remaining capacity"
	}
	elseif ($Volume.FileSystem -eq "NTFS" -or $Volume.FileSystem -eq "ReFS" -and $Volume.HealthStatus -eq "Healthy" -and $Volume.PercentFree -lt 10) {
		write-host "Volume" $Volume.Driveletter $Volume.FileSystemLabel "on Server" $env:Computername "is " -NoNewline
		write-host $Volume.HealthStatus -ForegroundColor green -NoNewline
		write-host " with " -NoNewline
		write-host $Volume.PercentFree -ForegroundColor red -NoNewline
		write-host " remaining capacity"
	}
	elseif ($Volume.FileSystem -eq "NTFS" -or $Volume.FileSystem -eq "ReFS" -and $Volume.HealthStatus -ne "Healthy" -and $Volume.PercentFree -gt 10) {
		write-host "Volume" $Volume.Driveletter $Volume.FileSystemLabel "on Server" $env:Computername "is " -NoNewline
		write-host $Volume.HealthStatus -ForegroundColor red -NoNewline
		write-host " with " -NoNewline
		write-host $Volume.PercentFree -ForegroundColor green -NoNewline
		write-host " remaining capacity"
	}
	elseif ($Volume.FileSystem -eq "NTFS" -or $Volume.FileSystem -eq "ReFS" -and $Volume.HealthStatus -ne "Healthy" -and $Volume.PercentFree -lt 10) {
		write-host "Volume" $Volume.Driveletter $Volume.FileSystemLabel "on Server" $env:Computername "is " -NoNewline
		write-host $Volume.HealthStatus -ForegroundColor red -NoNewline
		write-host " with " -NoNewline
		write-host $Volume.PercentFree -ForegroundColor red -NoNewline
		write-host " remaining capacity"
	}
}