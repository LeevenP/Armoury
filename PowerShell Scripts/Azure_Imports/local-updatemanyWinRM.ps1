<# 
Version 2.2

 .Synopsis
  Sets machine settings for multiple VMs calling local-winrmupdateswsus.ps1

 .Description
 Takes input from file
 The script expects a file as input in the same folder as this script, the private IP address,  name of newVM on each line. 
    
 .Parameter ResourceGroupName -> The name of the  resource group in which that VMs and\ storage will be. e.g. VBPNext.
 
 .Parameter $filename-> Name of the file tha contains the list of hosts fields separated by TABs IPAddess Hostname Description use underscore to keep files together
             file must be in the location where the script is run.  

 .Parameter $JumpboxIP -> IP address of the Jumpbox
  
 .Parameter $Username -> Username to be uesed by WINRM 

 .Parameter $PASSWORD -> password to be uesed by WINRM
 
 .Parameter $WSUSURL -> The URL of the WSUS server.  
  
 .Parameter $rootdomain -> The name of the root DNSdomain against which the VMs will be registeredn. e.g. "awazdevtest.net" 
  
 .Parameter $DNSServer -> The IP of the  DNS server to regster against 
  
 .Parameter $Cloud = Select in which cloud will this script run this is case sensitive: options are "Azure" or "AWS"
  
 .Example
 ./local-updatemanyWinRM.ps1  -ResourceGroupName  "UserSeg" -filename  ".\Hosts.txt" -JUMPBOXIP "10.58.4.6" -username "bluemesa" -PASSWORD  "password1234$"  -WSUSURL "http://AWSWEDV003.awhead.awazdevtest.net:8530" `
    -rootdomain  "awazdevtest.net" -DNSserver  "10.99.1.150" -Cloud   "Azure

#>
Param
(  
	$ResourceGroupName = "UserSeg",
    $filename = ".\Hosts.txt",
    $JUMPBOXIP = "10.58.4.6",
    $username = "bluemesa",
    $PASSWORD = "password1234$",
    $WSUSURL = "http://AWSWEDV003.awhead.awazdevtest.net:8530",
    $rootdomain = "awazdevtest.net",
    $DNSserver = "10.99.1.150",
    $Cloud  = "Azure"
)


$items = Get-Content $filename 
ForEach ($item in $items) { 
    $parts = $item -split '\s+'
    $VMIP = $parts[0]
    $vmname = $parts[1]
    $readdesc = $parts[2]
    If ($vmname -eq $null) {
    Write-output "Null entry for machine "
    break}  
.\local-winrmupdateswsus.ps1 -ResourceGroupName "UserSeg" -JUMPBOXIP $JUMPBOXIP -username "bluemesa" -PASSWORD "password1234$" -WSUSURL "http://AWSWEDV003.awhead.awazdevtest.net:8530" -rootdomain "awazdevtest.net" `
    -DNSserver "10.99.1.150" -serverIP  $VMIP -servername $vmname -Cloud  $Cloud
.\local-winrmupdateswsus.ps1 -ResourceGroupName "UserSeg" -JUMPBOXIP $JUMPBOXIP -username "solarc" -PASSWORD "bH!87yK_D" -WSUSURL "http://AWSWEDV003.awhead.awazdevtest.net:8530" -rootdomain "awazdevtest.net" `
    -DNSserver "10.99.1.150" -serverIP  $VMIP -servername $vmname -Cloud  $Cloud
    Write-Host "Completed :" $vmname 
}
Write-Host "Job Completed !!!!"


