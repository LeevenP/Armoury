#Author = Leeven Padayachee 


Connect-VIServer -Server 10.1.101.xx 
Connect-CIServer -Server 10.1.101.xx -user administrator -password 8lu3m3`$a -wa 0

$CIvAppName = "Xclusivestudios 2 - 38.26 (ID2)"



#Trusted Segment--------------------------------------------------------------------------------------------
write-host `n`n"Setting VM network settings for each vm"

    $CIVMs = get-CIvApp $CIvAppName | get-civm |? {$_.name -like "*DB*"}
   $OrgNetTrusted =  (get-CIvApp $CIvAppName | Get-CIVAppNetwork | ? {$_.Name -Like "*Trusted*"}).Name
Foreach ($vm in $CIVMs) {
    $Net = ($vm.ExtensionData.Section | Where {$_.GetType() -like "*networkConnectionSection"})
    $Network = $Net.NetworkConnection[0]
    $Network.Network = $OrgNetTrusted
    $Network.NeedsCustomization = $true
    $Network.IsConnected = $true
    $Network.IpAddressAllocationMode = "POOL"
   
    $net.UpdateServerData()
}

#DMZ Segment-------------------------------------------------------------------------------------------
write-host `n`n"Setting VM network settings for each vm"

    $CIVMs = get-CIvApp $CIvAppName | get-civm |? {$_.name -notlike "*DB*"}
   $OrgNetDMZ =  (get-CIvApp $CIvAppName | Get-CIVAppNetwork | ? {$_.Name -Like "*DMZ*"}).Name
Foreach ($vm in $CIVMs) {
    $Net = ($vm.ExtensionData.Section | Where {$_.GetType() -like "*networkConnectionSection"})
    $Network = $Net.NetworkConnection[0]
    $Network.Network = $OrgNetDMZ
    $Network.NeedsCustomization = $true
    $Network.IsConnected = $true
    $Network.IpAddressAllocationMode = "POOL"
   
    $net.UpdateServerData()
}