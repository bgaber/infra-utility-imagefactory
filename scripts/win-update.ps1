# Source : https://github.com/hashicorp/best-practices/blob/master/packer/scripts/windows/install_windows_updates.ps1
# Silence progress bars in PowerShell, which can sometimes feed back strange
# XML data to the Packer output.
$ProgressPreference = "SilentlyContinue"

Write-Output "Starting PSWindowsUpdate Installation"
# Install PSWindowsUpdate for scriptable Windows Updates
$webDeployURL = "https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc/file/66095/1/PSWindowsUpdate_1.4.5.zip"
$filePath = "$($env:TEMP)\PSWindowsUpdate.zip"

(New-Object System.Net.WebClient).DownloadFile($webDeployURL, $filePath)

# Older versions of Powershell do not have 'Expand Archive'
# Use Shell.Application custom object to unzip
# https://stackoverflow.com/questions/27768303/how-to-unzip-a-file-in-powershell
$shell = New-Object -ComObject Shell.Application
$zipFile = $shell.NameSpace($filePath)
$destinationFolder = $shell.NameSpace("C:\Program Files\WindowsPowerShell\Modules")

$copyFlags = 0x00
$copyFlags += 0x04 # Hide progress dialogs
$copyFlags += 0x10 # Overwrite existing files

$destinationFolder.CopyHere($zipFile.Items(), $copyFlags)
# Clean up
Remove-Item -Force -Path $filePath

Write-Output "Ended PSWindowsUpdate Installation"

Write-Output "Starting Windows Update Installation"

Try 
{
    Import-Module PSWindowsUpdate -ErrorAction Stop
}
Catch
{
    Write-Error "Unable to install PSWindowsUpdate"
    exit 1
}

if (Test-Path C:\Windows\Temp\PSWindowsUpdate.log) {
    # Save old logs
    Rename-Item -Path C:\Windows\Temp\PSWindowsUpdate.log -NewName PSWindowsUpdate-$((Get-Date).Ticks).log

    # Uncomment the line below to delete old logs instead
    #Remove-Item -Path C:\Windows\Temp\PSWindowsUpdate.log
}

try {
    $updateCommand = {Import-Module PSWindowsUpdate; Get-WUInstall -AcceptAll -IgnoreReboot | Out-File C:\Windows\Temp\PSWindowsUpdate.log}
    $TaskName = "PackerUpdate"

    $User = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Scheduler = New-Object -ComObject Schedule.Service

    $Task = $Scheduler.NewTask(0)

    $RegistrationInfo = $Task.RegistrationInfo
    $RegistrationInfo.Description = $TaskName
    $RegistrationInfo.Author = $User.Name

    $Settings = $Task.Settings
    $Settings.Enabled = $True
    $Settings.StartWhenAvailable = $True
    $Settings.Hidden = $False

    $Action = $Task.Actions.Create(0)
    $Action.Path = "powershell"
    $Action.Arguments = "-Command $updateCommand"

    $Task.Principal.RunLevel = 1

    $Scheduler.Connect()
    $RootFolder = $Scheduler.GetFolder("\")
    $RootFolder.RegisterTaskDefinition($TaskName, $Task, 6, "SYSTEM", $Null, 1) | Out-Null
    $RootFolder.GetTask($TaskName).Run(0) | Out-Null

    Write-Output "The Windows Update log will be displayed below this message. No additional output indicates no updates were needed."
    do {
		Start-Sleep 1
		if ((Test-Path C:\Windows\Temp\PSWindowsUpdate.log) -and $null -eq $script:reader) {
			$script:stream = New-Object System.IO.FileStream -ArgumentList "C:\Windows\Temp\PSWindowsUpdate.log", "Open", "Read", "ReadWrite"
			$script:reader = New-Object System.IO.StreamReader $stream
		}
		if ($null -ne $script:reader) {
			$line = $Null
			do {$script:reader.ReadLine()
				$line = $script:reader.ReadLine()
				Write-Output $line
			} while ($null -ne $line)
		}
	} while ($Scheduler.GetRunningTasks(0) | Where-Object {$_.Name -eq $TaskName})
} finally {
    $RootFolder.DeleteTask($TaskName,0)
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Scheduler) | Out-Null
	if ($null -ne $script:reader) {
		$script:reader.Close()
		$script:stream.Dispose()
	}
}
Write-Output "Ended Windows Update Installation"