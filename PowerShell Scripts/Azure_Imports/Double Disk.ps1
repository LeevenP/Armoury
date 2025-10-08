param
(
    $subscriptionName = "DerivcoAZDevTest",
    $Storageprefix = "sc",
    $ResourceGroupName = "Pokerstars",
    $AzureDataCenter = "West Europe",
    $NetworkRGPrefix =  "LandP",
    $project = "PE Scalability"
)

#Login-AzureRmAccount

./AZ-clone-dualdiskVM.ps1 -subscriptionName $subscriptionName -Storageprefix  $Storageprefix -ResourceGroupName  $ResourceGroupName -AzureDataCenter $AzureDataCenter `
-NetworkRGPrefix   $NetworkRGPrefix -project  $project -vmName  "GamingDB2" -vmSize "Standard_DS15_v2" -diskName  "gamingdb2_disk0.vhd" `
-IsLinux $false -dataDiskName  "gamingdb2_disk1.vhd"  -dataDiskSizeInGb 20 -datadiskprem 3 


