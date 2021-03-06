# Put samba.txt and primary.txt in same folder as this script

# Modify Execution policy for the computer, Default=Restricted
Set-ExecutionPolicy Unrestricted
cd c:\temp

# Get/set active ipv4 address and gateway
$ipc=gwmi -Class win32_networkadapterconfiguration | Where-Object {$_.ipenabled -eq $true}
$ipc.SetDNSServerSearchOrder()
$ipc.EnableDHCP()
$ip=$ipc.ipaddress[0]


# Split then Join to get Network id - based on /24 mask 
$j=$ip.split(".")
$join= $j[0],$j[1],$j[2] -join "."

# Search samba.txt for match, assign samba ip/name/domain vars
$s=Get-Content c:\temp\samba.txt | Select-String -Pattern $join\s
$s=$s.tostring()
$s=$s.split(" ")
$net=$s[0]
$pdc_ip=$s[1]
$pdc_name=$s[2]
$dom=$s[3]


# Modify Hosts
If (Test-Path "C:\windows\system32\drivers\etc\hosts")
 {copy-item -force C:\WINDOWS\system32\drivers\etc\hosts -destination C:\WINDOWS\system32\drivers\etc\hosts.old;
 clear-Content -force $env:windir\system32\drivers\etc\hosts 
 }
Else {write-host "Hosts file not found"}

# Add 2 reg entries for Win7/Samba domain compatibility
$LM= 'HKLM:\SYSTEM\CurrentControlSet\services\LanmanWorkstation\Parameters'
Remove-ItemProperty -Path $LM  -Name DomainCompatibilityMode  | Out-Null
Remove-ItemProperty -Path $LM  -Name DNSNameResolutionRequired | Out-Null
Restart-Service Workstation -force

Stop-Service EventSystem -force
foreach ($p in (get-wmiobject win32_service -filter "name='CscService' OR name='SENS'")) {if ($p.state -eq "running") `
{$p.StopService()}} ; {if($p.startmode -ne "disabled") {$p.ChangeStartMode("disabled")}} | Out-Null

# Samba Domain joining
 function UnJoinDomain ([string]$user, [string]$Password) {
 $domainUser= $Domain + "\" + $User
 $computersystem= gwmi Win32_Computersystem
 $computerSystem.UnJoinDomainOrWorkgroup($Password,$DomainUser,0)
 }
 
#if join succeeds, restart computer
 Write-Host -ForegroundColor blue -BackgroundColor white "Joining to workgroup..."
 if (UnJoinDomain admin pipadmin)  {Restart-Computer -force}
 
 Set-ExecutionPolicy Unrestricted