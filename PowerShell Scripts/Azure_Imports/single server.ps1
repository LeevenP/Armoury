param
(
    $subscriptionName = "insert subscription name here",
    $Storageprefix = "sc",
    $ResourceGroupName = "Pokerstars",
    $AzureDataCenter = "West Europe",
    $NetworkRGPrefix =  "LandP",
    $project = "PE Scalability"
)

./AZ-clone-singlediskVM.ps1 -subscriptionName $subscriptionName -Storageprefix  $Storageprefix -ResourceGroupName  $ResourceGroupName -AzureDataCenter $AzureDataCenter `
-NetworkRGPrefix   $NetworkRGPrefix -project  $project -vmName  "GamingDB2" -vmSize "Standard_DS3_v2" -diskName  "gamingdb2_disk0.vhd" `
-IsLinux $false 

#./ AZ-clone-singlediskVM.ps1 -subscriptionName $subscriptionName -Storageprefix  $Storageprefix -ResourceGroupName  $ResourceGroupName -AzureDataCenter $AzureDataCenter `
#   -NetworkRGPrefix   $NetworkRGPrefix -project  $project -vmName  "ServFabric05" -vmSize "Standard_DS1_v2" -diskName  "Win2012r2-osdisk.vhd" `
#   -IsLinux $false 

#./ AZ-clone-dualdiskVM.ps1 -subscriptionName $subscriptionName -Storageprefix  $Storageprefix -ResourceGroupName  $ResourceGroupName -AzureDataCenter $AzureDataCenter `
#-NetworkRGPrefix   $NetworkRGPrefix -project  $project -vmName  "ArchDB" -vmSize "Standard_DS1_v2" -diskName  "NewGamingDB1-Disk1.vhd" `
#-IsLinux $false -dataDiskName  "NewGamingDB1-Disk2.vhd"  -dataDiskSizeInGb 20 -datadiskprem 3 

#./AZ-clone-dualdiskVM.ps1-subscriptionName $subscriptionName -Storageprefix  $Storageprefix -ResourceGroupName  $ResourceGroupName -AzureDataCenter $AzureDataCenter `
#-NetworkRGPrefix   $NetworkRGPrefix -project  $project -vmName  "GamingDB7" -vmSize "Standard_DS2_v2" -diskName  "GamingDB7-Disk1.vhd" `
#-dataDiskName  "GamingDB7-Disk2.vhd"  -dataDiskSizeInGb 80 -datadiskprem 0 -IsLinux $False
  
