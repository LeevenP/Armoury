<# 
Version 2.3

 .Synopsis
  Sets machine setings via WINRM

 .Description
 Sets machine DNS,WSUS, offline drives, host files, installs Azure agent.
   
 .Parameter ResourceGroupName -> The name of the  resource group in which that VMs and\ storage will be. e.g. VBPNext.

 .Parameter $JumpboxIP -> IP address of the Jumpbox
  
 .Parameter $Username -> Username to be uesed by WINRM 

 .Parameter $PASSWORD -> password to be uesed by WINRM
 
 .Parameter $WSUSURL -> The URL of the WSUS server.  
  
 .Parameter $rootdomain -> The name of the root DNSdomain against which the VMs will be registeredn. e.g. "awazdevtest.net" 
  
 .Parameter $DNSServer -> The IP of the  DNS server to regster against 
  
 .Parameter $ServerIP -> The IP of the server that will be configured

 .Parameter $Servername -> The name of the server that will be configured so nam can be set.

 .Parameter $Cloud = Select in which cloud will this script run this is case sensitive: options are "Azure" or "AWS"
  
 .Example
 ./local-winrmupdateswsus.ps1  -ResourceGroupName "VBPNext" -ResourceGroupName  "UserSeg" -JUMPBOXIP "10.58.4.6" -username "bluemesa" -PASSWORD  "password1234$"  -WSUSURL "http://AWSWEDV003.awhead.awazdevtest.net:8530" `
    -rootdomain  "awazdevtest.net" -DNSserver  "10.99.1.150" -serverIP = "10.58.4.106" -servername "webserver402 -Cloud  "Azure

#>

Param
(  
	$ResourceGroupName = "UserSeg",
    $JUMPBOXIP = "10.58.4.6",
    $username = "bluemesa",
    $PASSWORD = "password1234$",
    $WSUSURL = "http://AWSWEDV003.awhead.awazdevtest.net:8530",
    $rootdomain = "awazdevtest.net",
    $DNSserver = "10.99.1.150",
    $serverIP = "10.58.4.106",
    $servername = "webserver402",
    $Cloud = "Azure"
)


$scriptBlock = {

$IenvironmentName = $args[0]
$Irootdomain = $args[1]
$Idomain = $IenvironmentName.ToLower() + "." + $Irootdomain 
$IDNSserver = $args[2]
$IserverIP = $args[3]
$Iservername = $args[4]
$IFQDN = $Iservername + "." +$Idomain
$Isearchlist = $Idomain + "," + $Irootdomain
$IJumpboxIP = $args[5]
$IWSUSURL = $args[6]
$scrusername = $args[7]
$scrPASSWORD = $args[8]
$Icloud = $args[9]



Function diskonline {
 $offlineDisks = "list disk" | diskpart | where { $_ -match "offline" } 

	# if offline disk(s) exist 
    if ($offlineDisks) { 
     foreach ($disk in $offlineDisks)  { 
     
            $offlineDisk = $disk.Substring(2,6) 
            
			# command to turn offline disk online.
			$turnOnlineCommand = @" 
				SELECT $offlineDisk 
				ATTRIBUTES DISK clear readonly 
				ONLINE DISK 
				ATTRIBUTES DISK clear readonly 
"@ 
            
            $response = $turnOnlineCommand | diskpart      
		} 
    } 
 }

#SQL
Write-Output "Setting SQL instance IPs"
	
	try {
		$mssqlRegistyPath = (Get-ChildItem -Path 'HKLM:\software\microsoft\microsoft sql server' | Where-Object {$_.Name -like "*MSSQL*.*" -and $_.Property -like "(default)" })[0].Name
		if (![string]::IsNullOrWhiteSpace($mssqlRegistyPath)) {
			$mssqlRegistyPath = $mssqlRegistyPath.Replace("HKEY_LOCAL_MACHINE", "HKLM:")
			$tcpSockets = Get-ChildItem -Path "$mssqlRegistyPath\MSSQLServer\SuperSocketNetLib\Tcp"
			foreach ($socket in $tcpSockets) {
				$regPath = $socket.Name.Replace("HKEY_LOCAL_MACHINE", "HKLM:")						
				$ipAddress = (Get-ItemProperty -Path $regPath).IpAddress
                write-host $ipAddress
				if ($ipAddress -like "192.168.*.*") {					
					New-ItemProperty -Path $regPath -Name IpAddress -Value $IserverIP -PropertyType String -Force | Out-Null
				}								
			}
		}
		else {
Write-Output "No instance found for this server"
		}		
	}
	catch {
		$errorMsg = "An error occured: " + $_.Exception.Message
		Write-Error $errorMsg
	}
   

#DNS
Write-Output "Setting DNS"  
 $RegKey = “HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\”
 if (Test-Path $RegKey) {
        Set-ItemProperty -Path “$RegKey” -Name “SearchList” -Type String -Value $Isearchlist
        Set-ItemProperty -Path “$RegKey” -Name “NV Domain” -Type String -Value $Idomain
     }   
    $1RegKey = “HKLM:\SOFTWARE\Microsoft\Virtual Machine\Auto”
    if (Test-Path $1RegKey) {
       Set-ItemProperty -Path “$1RegKey” -Name “FullyQualifiedDomainName” -Type String -Value $IFQDN
  }
$registry = Get-ChildItem "HKLM:\SYSTEM\ControlSet001\Services\Tcpip\Parameters\Interfaces" -Recurse
Foreach($a in $registry) {
    #Write-Output $a.PSChildName
    $subkeys = (Get-ItemProperty  $a.pspath) 
    if  (($subkeys.DhcpIPAddress -eq $IserverIP) -or ($subkeys.IPAddress -eq $IserverIP)){
    $i2RegKey = “HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\” + $a.PSChildName
    if (Test-Path $i2RegKey) {
       Set-ItemProperty -Path “$i2RegKey” -Name “RegistrationEnabled” -Type DWORD -Value 1
       Set-ItemProperty -Path “$i2RegKey” -Name “RegisterAdapterName” -Type DWORD -Value 1
       Set-ItemProperty -Path “$i2RegKey” -Name “NameServer" -Type STRING -Value $IDNSserver
       Set-ItemProperty -Path “$i2RegKey” -Name “Domain" -Type STRING -Value $Idomain
 #WSUS  
 Write-Output "Setting WSUS"   
 $RegKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
 if (Test-Path $RegKey) {
        Set-ItemProperty -Path “$RegKey” -Name “WUServer” -Type String -Value $IWSUSURL
        Set-ItemProperty -Path “$RegKey” -Name “WUStatusServer” -Type String -Value $IWSUSURL
        Set-ItemProperty -Path “$RegKey” -Name “ElevateNonAdmins” -Type DWORD -Value 1
        Set-ItemProperty -Path “$RegKey” -Name “TargetGroupEnabled” -Type DWORD -Value 1
        Set-ItemProperty -Path “$RegKey” -Name “TargetGroup" -Type STRING -Value "Servers"
        Set-ItemProperty -Path “$RegKey” -Name “AcceptTrustedPublisherCerts” -Type DWORD -Value 1
     }
 else {
        New-Item -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
        Set-ItemProperty -Path “$RegKey” -Name “WUServer” -Type String -Value $IWSUSURL
        Set-ItemProperty -Path “$RegKey” -Name “WUStatusServer” -Type String -Value $IWSUSURL
        Set-ItemProperty -Path “$RegKey” -Name “ElevateNonAdmins” -Type DWORD -Value 1
        Set-ItemProperty -Path “$RegKey” -Name “TargetGroupEnabled” -Type DWORD -Value 1
        Set-ItemProperty -Path “$RegKey” -Name “TargetGroup" -Type STRING -Value "Servers"
        Set-ItemProperty -Path “$RegKey” -Name “AcceptTrustedPublisherCerts” -Type DWORD -Value 1
      }
             
 $RegKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
 if (Test-Path $RegKey) {
        Set-ItemProperty -Path “$RegKey” -Name “AUOptions” -Type DWORD -Value 5
        Set-ItemProperty -Path “$RegKey” -Name “AutoInstallMinorUpdates” -Type DWORD -Value 0
        Set-ItemProperty -Path “$RegKey” -Name “DetectionFrequency" -Type DWORD -Value 16
        Set-ItemProperty -Path “$RegKey” -Name “DetectionFrequencyEnabled” -Type DWORD -Value 1

        Set-ItemProperty -Path “$RegKey” -Name “NoAutoRebootWithLoggedOnUsers” -Type DWORD -Value 5
        Set-ItemProperty -Path “$RegKey” -Name “NoAutoUpdate” -Type DWORD -Value 0
        Set-ItemProperty -Path “$RegKey” -Name “RebootRelaunchTimeout" -Type DWORD -Value 1
        Set-ItemProperty -Path “$RegKey” -Name “RebootRelaunchTimeoutEnabled” -Type DWORD -Value 1

        Set-ItemProperty -Path “$RegKey” -Name “RebootWarningTimeoutEnabled" -Type DWORD -Value 1
        Set-ItemProperty -Path “$RegKey” -Name “RebootWarningTimeout” -Type DWORD -Value 15
        Set-ItemProperty -Path “$RegKey” -Name “RescheduleWaitTimeEnabled" -Type DWORD -Value 1
        Set-ItemProperty -Path “$RegKey” -Name “RescheduleWaitTime” -Type DWORD -Value 30
        
        Set-ItemProperty -Path “$RegKey” -Name “ScheduledInstallDay" -Type DWORD -Value 0
        Set-ItemProperty -Path “$RegKey” -Name “ScheduledInstallTime” -Type DWORD -Value 15
        Set-ItemProperty -Path “$RegKey” -Name “NoAUShutdownOption" -Type DWORD -Value 0
        Set-ItemProperty -Path “$RegKey” -Name “NoAUAsDefaultShutdownOption” -Type DWORD -Value 1
        Set-ItemProperty -Path “$RegKey” -Name “UseWUServer” -Type DWORD -Value 1
        }
 else {
        New-Item -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
        Set-ItemProperty -Path “$RegKey” -Name “AUOptions” -Type DWORD -Value 5
        Set-ItemProperty -Path “$RegKey” -Name “AutoInstallMinorUpdates” -Type DWORD -Value 0
        Set-ItemProperty -Path “$RegKey” -Name “DetectionFrequency" -Type DWORD -Value 16
        Set-ItemProperty -Path “$RegKey” -Name “DetectionFrequencyEnabled” -Type DWORD -Value 1

        Set-ItemProperty -Path “$RegKey” -Name “NoAutoRebootWithLoggedOnUsers” -Type DWORD -Value 5
        Set-ItemProperty -Path “$RegKey” -Name “NoAutoUpdate” -Type DWORD -Value 0
        Set-ItemProperty -Path “$RegKey” -Name “RebootRelaunchTimeout" -Type DWORD -Value 1
        Set-ItemProperty -Path “$RegKey” -Name “RebootRelaunchTimeoutEnabled” -Type DWORD -Value 1

        Set-ItemProperty -Path “$RegKey” -Name “RebootWarningTimeoutEnabled" -Type DWORD -Value 1
        Set-ItemProperty -Path “$RegKey” -Name “RebootWarningTimeout” -Type DWORD -Value 15
        Set-ItemProperty -Path “$RegKey” -Name “RescheduleWaitTimeEnabled" -Type DWORD -Value 1
        Set-ItemProperty -Path “$RegKey” -Name “RescheduleWaitTime” -Type DWORD -Value 30
        
        Set-ItemProperty -Path “$RegKey” -Name “ScheduledInstallDay" -Type DWORD -Value 0
        Set-ItemProperty -Path “$RegKey” -Name “ScheduledInstallTime” -Type DWORD -Value 15
        Set-ItemProperty -Path “$RegKey” -Name “NoAUShutdownOption" -Type DWORD -Value 0
        Set-ItemProperty -Path “$RegKey” -Name “NoAUAsDefaultShutdownOption” -Type DWORD -Value 1
        Set-ItemProperty -Path “$RegKey” -Name “UseWUServer” -Type DWORD -Value 1
        }
       }
    }
   } 


$scrsecureString = ConvertTo-SecureString -AsPlainText -Force -String $scrPASSWORD

# use secure string to create credential object
$scrcredential = New-Object `
	-TypeName System.Management.Automation.PSCredential `
	-ArgumentList $scrusername,$scrsecureString
Write-Output "connecting to remote drive"  
    $bluemesadir = "C:\BluemesaAdmin"
   Try
    {
        New-PSDrive -Name "Q" -PSProvider "FileSystem" -Root "\\$IJumpboxIP\etc" -Credential $scrcredential -ErrorAction Stop 
     }
   Catch 
    {
        New-PSDrive -Name "Q" -PSProvider "FileSystem" -Root "\\$IJumpboxIP\etc"   
     }

    Copy-Item Q:\hosts C:\Windows\System32\drivers\etc\hosts  -ErrorAction SilentlyContinue 

   Try
    {
          New-PSDrive -Name "P" -PSProvider "FileSystem" -Root "\\$IJumpboxIP\Software" -Credential $scrcredential -ErrorAction Stop 
     }
   Catch 
    {
       New-PSDrive -Name "P" -PSProvider "FileSystem" -Root "\\$IJumpboxIP\Software" 
    }

if ($Icloud -eq "Azure") {
    write-Output "Installing Azure Agent"
   if (-not (Test-Path $bluemesadir)) { 
        New-Item $bluemesadir -type directory} 
    Copy-Item P:\WindowsAzureVmAgent.2.7.1198.778.rd_art_stable.160617-1120.fre.msi $bluemesadir -ErrorAction SilentlyContinue
    Start-Process  C:\BluemesaAdmin\WindowsAzureVmAgent.2.7.1198.778.rd_art_stable.160617-1120.fre.msi -ArgumentList /qn -wait
    }
Write-Output "Setting Licence" 
    $verstr = Get-WmiObject -Class Win32_OperatingSystem | ForEach-Object -MemberName Caption
    if ($verstr.contains("2008")) {
    Copy-Item P:\activate2008.bat $bluemesadir
    Start-Process  C:\BluemesaAdmin\activate2008.bat -wait
    }
    if ($verstr.contains("2012")) {
    Copy-Item P:\Activate2012.bat $bluemesadir
    Start-Process  C:\BluemesaAdmin\Activate2012.bat -wait
    }
    Write-Output "Setting Disks online"  
    diskonline

    if (((Get-Service wuauserv).starttype -eq "Disabled") -or ((Get-Service wuauserv).starttype -eq "Manual")){
    Set-Service wuauserv -startuptype "Automatic"}
   Try
    {

         Start-Service wuauserv -ErrorAction Stop
    }
   Catch [SystemException]
    {
        Write-Output "cannot start windows update"   
    }
    
    Try
    {

        Rename-Computer -NewName $Iservername  -LocalCredential $scrcredential -Restart  -ErrorAction Stop 
    }
   Catch 
    {

        Restart-Computer -computername $Iservername -Force -Credential $scrcredential   
    
    }

}

$secureString = ConvertTo-SecureString -AsPlainText -Force -String $PASSWORD

# use secure string to create credential object
$credential = New-Object `
	-TypeName System.Management.Automation.PSCredential `
	-ArgumentList $username,$secureString
    Try
    {
        $Session = New-PSSession -ComputerName $serverIP -Credential $credential -ErrorAction stop
    }
   Catch 
    {
       Write-Output "Could not connect to $servername"
      Return   
    }
 
Write-Output "Creadted session"  
Invoke-Command -Session $Session -ScriptBlock $scriptBlock -ArgumentList $ResourceGroupName,$rootdomain,$DNSserver,$serverIP,$servername,$JumpboxIP,$WSUSURL,$username,$PASSWORD,$Cloud 
Write-Output "Called remote code"  
EXIT
Exit-PSSession -Session $Session
