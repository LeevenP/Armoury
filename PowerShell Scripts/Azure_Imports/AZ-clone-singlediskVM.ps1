
<# 
Version2.3
 .Synopsis
  Clones a VM with a single disk.

 .Description
  The script expects a file called NewHosts.txt in the same folder as this script, the private IP address,  name of newVM and description
  on each line.   The script uses a convention to name the network adapter based on the hostnames in the file. It also uses a convention to
  lookup the publib IP address, which should have been created prior to running this script. Use "createEnvironmentPublicIpAddresses.ps1".
  Convention = {SubnetName}_{hostname}_NIC 

 .Parameter subscriptionName -> Name of the subscription e.g. "DerivcoAZDevTest"

 .Parameter Storageprefix -> prefix for accounts enabling them to be unique e.g. "sc"
 
 .Parameter ResourceGroupName -> The name of the  resource group in which that VMs and\ storage will be. e.g. VBPNext.

 .Parameter $AzureDataCenter ->The region in which resources will be placed. e.g.  "West Europe"
  
 .Parameter $NetworkRGPrefix -> The prefixed used to determine names of network RG, Vnet and Security group . e.g. LandP 
   
 .Parameter $project -> The name of Project the environment belongs to for tagging and billingnetwork adapters. e.g. "PE Scalability"

 .Parameter $vmName -> The name of the VM e.g. Test
 
 .Parameter $vmSize -> The size CPU MEM spec choseen from list of sizes e.g. "Standard_DS1_v2"
  
 .Parameter $diskName -> The image file name of the OS disk (Case sensitive) e.g."Win2012r2-osdisk.vhd"
 
 .Parameter $AvailabilitySet -> This parmeteter in live can be used to ensure VMs that provide a specific service are on different infrastructure. 
    It is also required to put VMs in loadbalancer pool when using azure LB. It is just the name of the group. e.g.  "Webservers" 
  
 .Parameter $IsLinux  -> Use to mark whther the VM is Linux or windows. eg. $False
 
 
 .Example
 ./AZ-clone-singlediskVM -subscriptionName "DerivcoAZDevTest" -Storageprefix  "sc" -ResourceGroupName  "UserSeg" -AzureDataCenter "West Europe" `
    -NetworkRGPrefix   "LandP" -project  "PE Scalability" -vmName  "test" -vmSize "Standard_DS1_v2" -diskName  "Win2012r2-osdisk.vhd" `
    $AvailabilitySet "manytest" -IsLinux $false
    
#>

param
(
    $subscriptionName = "insert subscription name here",
    $Storageprefix = "sc",
    $ResourceGroupName = "Pokerstars",
    $AzureDataCenter = "West Europe",
    $NetworkRGPrefix =  "LandP",
    $project = "PE Scalability",
    $vmName = "CasinoAS1",
    $vmSize = "Standard_DS1_v2",
    $diskName = "CasinoAS1_36.08_Disk0.vhd",
    $AvailabilitySet = $null,
    $IsLinuxbox = $false
)

$vnetname = $NetworkRGPrefix + "Network"
$NetworkRGName = $NetworkRGPrefix + "Network"
$SecurityGroupName =  $ResourceGroupName + "SecGrp"
$Subnetname = "Subnet" + $ResourceGroupName
$environmentName = $ResourceGroupName
$tags = @{"Name" = "Environment"; "Value" = $environmentName}, @{"Name" = "Project"; "Value" = $project}

$PremStorageAccname = $Storageprefix + $ResourceGroupName.ToLower() + "premstore"
$StdStorageAccname =  $Storageprefix + $ResourceGroupName.ToLower() + "stdstore"
$StdBootdiagAccname = $Storageprefix + $ResourceGroupName.ToLower() + "stddiag"
$destStorageAccname = $StdStorageAccname

$tags = @{"Name" = "Environment"; "Value" = $environmentName}, @{"Name" = "Project"; "Value" = $project}
$sub = Select-AzureRmSubscription -SubscriptionName $subscriptionName

Function CopyVhd
{
    param
    (
        $CvhdName,
        $CSrcStorageAccname,
        $CResourceGroup,
        $CdestStorageAccname
    )
    Write-host "Copying $CvhdName" 
   
    $SrcStorageKey = ((Get-AzureRmStorageAccountKey -Name $CSrcStorageAccname -ResourceGroup $CResourceGroup) | select -First 1 -ExpandProperty value)
    $destStorageKey  = ((Get-AzureRmStorageAccountKey -Name $CdestStorageAccname  -ResourceGroup $CResourceGroup) | select -First 1 -ExpandProperty value)
    $srcContext  = New-AzureStorageContext -StorageAccountName $CSrcStorageAccname -StorageAccountKey $SrcStorageKey
    $srcUri = "https://" + $CSrcStorageAccname + ".blob.core.windows.net/source/" + $CvhdName
    $unixDate = Get-Date -UFormat %s
    $newFileName = $vmName.Replace(".vhd","") + "_" + $unixDate.Replace(",","_").Replace(".", "_") + ".vhd"
    $destContext = New-AzureStorageContext -StorageAccountName $CdestStorageAccname -StorageAccountKey $destStorageKey
    $copy = Start-AzureStorageBlobCopy  -srcUri $srcUri -SrcContext $srcContext -DestContainer "vhds" -DestBlob $newFileName `
     -DestContext $destContext
    $copyState = Get-AzureStorageBlob -Blob $newFileName -Container "vhds" -Context $destContext | Get-AzureStorageBlobCopyState

    While($copyState.Status -eq "Pending"){
     $copyState = Get-AzureStorageBlob -Blob $newFileName -Container "vhds" -Context $destContext | Get-AzureStorageBlobCopyState
     Start-Sleep 20
     }
    [string]$blobEndpoint = $destContext.BlobEndPoint 
    [string]$osDiskUri = $blobEndpoint + "vhds/$newFileName" 
    Return $osDiskUri
     }

$network = Get-AzureRmVirtualNetwork -ResourceGroupName $NetworkRGName -Name $vnetname | Select Subnets
$subnet = $network.Subnets | Where-Object { $_.Name -eq $subnetName }

Write-Output "Creating VM $vmName"

[string]$disk1 = CopyVhd -CvhdName $diskName -CSrcStorageAccname $StdStorageAccname -cdestStorageAccname $destStorageAccname `
  -CResourceGroup  $ResourceGroupName  

$disk1 = $disk1.ToString()
$nicName = $subnetName + "_" + $vmName + "_NIC"
$nic = Get-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $NetworkRGName
If ($AvailabilitySet -ne $null)
{
    Write-Host $AvailabilitySet
    $avSet = Get-AzureRmAvailabilitySet -Name $AvailabilitySet -ResourceGroupName $ResourceGroupName
    Write-Host $avSet
    $vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $avset.Id
} 
Else
{
    $vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize    
}
  
$osDiskName = $vmName + "_osDisk"

If ($IsLinux -eq $true)
{
    $vm = Set-AzureRmVMOSDisk -VM $vm -VhdUri $disk1 -name $osDiskName -CreateOption Attach -Linux -Caching "ReadWrite"
}
Else
{
   $vm = Set-AzureRmVMOSDisk -VM $vm -VhdUri $disk1 -name $osDiskName -CreateOption Attach -Windows -Caching "ReadWrite"
}

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $AzureDataCenter -VM $vm -Tags $tags

$BootVM = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vmName
Set-AzureRmVMBootDiagnostics -VM $BootVM -Enable -ResourceGroupName $ResourceGroupName -StorageAccountName $StdBootdiagAccname
Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $BootVM

Write-Output ">>Creating VM $vmName complete"