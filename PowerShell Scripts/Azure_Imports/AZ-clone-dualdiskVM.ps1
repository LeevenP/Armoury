
<# 
Version2.2
 .Synopsis
  Clones a VM with a dual disk.

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

 .Parameter $dataDiskName -> The image file name of the data disk (Case sensitive) e.g."Win2012r2-disk2.vhd"

  .Parameter $dataDiskSizeInGb -> this is either the existing size or the size you want the data disk to be e.g.20
  
  .Parameter $datadiskprem -> this detemine if the data disk must use premium storage default 0 means no .
      Anything other than 0 overides $dataDiskSizeInGb.  1 means 128 GB 1000 IOPS,  2 means 512 GB 2500, 3 means 1023 GB 5000 IOPS  , eg 3
       Note. If 1-3 are selected images mus be in the source container on the premium storage account.
        
  Example
  ./AZ-clone-dualdiskVM.ps1 -subscriptionName $subscriptionName -Storageprefix  $Storageprefix -ResourceGroupName  $ResourceGroupName -AzureDataCenter $AzureDataCenter `
-NetworkRGPrefix   $NetworkRGPrefix -project  $project -vmName  "ArchDB" -vmSize "Standard_DS2_v2" -diskName  "ArchDB-Disk1.vhd" `
 -dataDiskName  "ArchDB-Disk2.vhd"  -dataDiskSizeInGb 80 -datadiskprem 3 -IsLinux $False

#>

param
(
    $subscriptionName = "insert subscription name here",
    $Storageprefix = "sc",
    $ResourceGroupName = "UserSeg",
    $AzureDataCenter = "West Europe",
    $NetworkRGPrefix =  "LandP",
    $project = "PE Scalability",
    $vmName = "WebServer401",
    $vmSize = "Standard_DS1_v2",
    $diskName = "Webserver4-disk1.vhd",
    $AvailabilitySet = $null,
    $IsLinuxbox = $false,
    $dataDiskName = "Webserver4-disk2.vhd",
    $dataDiskSizeInGb = 20,
    $datadiskprem = 0
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

[string]$disk1 = CopyVhd -CvhdName $diskName -CSrcStorageAccname $StdStorageAccname -cdestStorageAccname $destStorageAccname -CResourceGroup  $ResourceGroupName  
$disk1 = $disk1.ToString()


switch ($datadiskprem ) {
    0{$destStorageAccname = $StdStorageAccname
       $IncdataDiskSizeInGb = 0}
    1{ $destStorageAccname = $PremStorageAccname
       $IncdataDiskSizeInGb = 128  
      }
    2{$destStorageAccname = $PremStorageAccname
      $IncdataDiskSizeInGb = 512
      }
    3{$destStorageAccname = $PremStorageAccname
      $IncdataDiskSizeInGb = 1023
      }
}

[string]$disk2 = CopyVhd -CvhdName $dataDiskName -CSrcStorageAccname $StdStorageAccname -cdestStorageAccname $destStorageAccname -CResourceGroup $ResourceGroupName  
$disk2 = $disk2.ToString()
#Write-Host "disk2uri : $disk2"
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
$vm = Add-AzureRmVMDataDisk -VM $vm -Name $vmName"Datadisk" -Caching "ReadOnly" -DiskSizeInGB $dataDiskSizeInGb -VhdUri $disk2 -CreateOption Attach -Lun 0
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $AzureDataCenter -VM $vm -Tags $tags

$BootVM = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $vmName
Set-AzureRmVMBootDiagnostics -VM $BootVM -Enable -ResourceGroupName $ResourceGroupName -StorageAccountName $StdBootdiagAccname

if ($IncdataDiskSizeInGb -ne 0)  {
    Stop-AzureRmVm -ResourceGroupName $ResourceGroupName -Name $vmName -Force
    Set-AzureRmVMDataDisk -Name $vmName"Datadisk"  -VM $BootVM -DiskSizeInGB $IncdataDiskSizeInGb
    Update-AzureRMVM -ResourceGroupName $ResourceGroupName -vm $BootVM
    Start-AzureRmVm -ResourceGroupName $ResourceGroupName -Name $vmName 
     }
else {Update-AzureRmVM -ResourceGroupName $ResourceGroupName -VM $BootVM}
  
Write-Output ">>Creating VM $vmName complete <<"
