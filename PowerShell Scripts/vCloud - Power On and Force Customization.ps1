#Author = Leeven Padayachee



#IOB----------------------------------
#Connect-VIServer -Server 10.75.4.xx
#Connect-CIServer -Server 10.75.4.xx -user administrator -password 8lu3m3`$a -wa 0


#FP-----------------------------------
Connect-VIServer -Server 10.1.101.xx 
Connect-CIServer -Server 10.1.101.xx -user administrator -password 8lu3m3`$a -wa 0

$ver = Read-Host "38.28"
$CIvAppName = "Account QA 01 - 38.28 (ID1)"
$OrgNetTrusted = "FP_OrgNet_Supercanister2_Trusted"
$OrgNetDMZ = "FP_OrgNet_Supercanister2_DMZ"



$CIVMs = get-CIvApp $CIvAppName | get-civm | sort
Foreach ($vm in $CIVMs) {
	$GuestCustomization = $vm.ExtensionData.Section | Where {$_.GetType() -like "*GuestCustomizationSection"}
	$GuestCustomization.Enabled = $true
	$GuestCustomization.any = $null
	$GuestCustomization.UpdateServerData()
}


#-----------------------------------------------------------------------------------------------------------------------------------
#this Will power on and force customisation for the environment above


$CIVMs = get-CIvApp $CIvAppName | get-civm
Foreach ($vm in $CIVMs) {
$vm.ExtensionData.Deploy($true,$true,0)
}
#Author = Leeven Padayachee



#IOB----------------------------------
#Connect-VIServer -Server 10.75.4.180
#Connect-CIServer -Server 10.75.4.181 -user administrator -password 8lu3m3`$a -wa 0


#FP-----------------------------------
Connect-VIServer -Server 10.1.101.xx 
Connect-CIServer -Server 10.1.101.xx -user administrator -password 8lu3m3`$a -wa 0

$ver = Read-Host "38.28"
$CIvAppName = "Account QA 01 - 38.28 (ID1)"
$OrgNetTrusted = "FP_OrgNet_Supercanister2_Trusted"
$OrgNetDMZ = "FP_OrgNet_Supercanister2_DMZ"



$CIVMs = get-CIvApp $CIvAppName | get-civm | sort
Foreach ($vm in $CIVMs) {
	$GuestCustomization = $vm.ExtensionData.Section | Where {$_.GetType() -like "*GuestCustomizationSection"}
	$GuestCustomization.Enabled = $true
	$GuestCustomization.any = $null
	$GuestCustomization.UpdateServerData()
}


#-----------------------------------------------------------------------------------------------------------------------------------
#this Will power on and force customisation for the environment above


$CIVMs = get-CIvApp $CIvAppName | get-civm
Foreach ($vm in $CIVMs) {
$vm.ExtensionData.Deploy($true,$true,0)
}
