#Login-AzureRmAccount

<# 
Version 2.2

 .Synopsis
  Creates environment resource groups, storage account, subnet sets the secirity groups 

 .Description
  The script expects a file as input in the same folder as this script, the private IP address,  name of newVM and description
  on each line.   The script uses a convention to name the network adapter based on the hostnames in the file.
  Convention = {SubnetName}_{hostname}_NIC 

 .Parameter subscriptionName -> Name of the subscription e.g. "DerivcoAZDevTest"

 .Parameter Storageprefix -> prefix for accounts enabling them to be unique e.g. "sc"
 
 .Parameter ResourceGroupName -> The name of the  resource group in which that VMs and\ storage will be. e.g. VBPNext.

 .Parameter $AzureDataCenter ->The region in which resources will be placed. e.g.  "West Europe"
  
 .Parameter $NetworkRGPrefix -> The prefixed used to determine names of network RG, Vnet and Security group . e.g. LandP 
 
 .Parameter $SubnetAddressPrefix -> The ipddress range which the environmet will use . e.g. 10.58.5.0/24

 .Parameter $NetworkPrefix -> The ipddress range of the "network head". e.g. 10.58.0.0/16
 
 .Parameter $project -> The name of Project the environment belongs to for tagging and billingnetwork adapters. e.g. "PE Scalability"


 .Example
 ./AZ-newenvironmentsetup.ps1 -subscriptionName  "DerivcoAZDevTest" -Storageprefix  "sc" -ResourceGroupName  "Pokerstars" -AzureDataCenter "West Europe" `
    -SubnetAddressPrefix  "10.58.5.0/24" -NetworkPrefix  "10.58.0.0/16" -NetworkRGPrefix   "LandP" -project  "PE Scalability"
    
#>



Param
(  
	$subscriptionName = "insert subscription name here",
    $Storageprefix = "sc",
    $ResourceGroupName = "BalanceBroker",
    $AzureDataCenter = "West Europe",
    $SubnetAddressPrefix ="10.58.6.0/24",
    $NetworkPrefix = "10.58.0.0/16",
    $NetworkRGPrefix =  "LandP",
    $project = "PE Scalability"
)

#Login-AzureRmAccount

#Parameters
$vnetname = $NetworkRGPrefix + "Network"
$NetworkRGName = $NetworkRGPrefix + "Network"
$SecurityGroupName =  $ResourceGroupName + "SecGrp"
$Subnetname = "Subnet" + $ResourceGroupName
$RouteTableName = $NetworkRGPrefix + "Network_routes"
$sub = Select-AzureRmSubscription -SubscriptionName $subscriptionName
$environmentName = $ResourceGroupName
$tags = @{"Name" = "Environment"; "Value" = $environmentName}, @{"Name" = "Project"; "Value" = $project}

$PremStorageAccname = $Storageprefix + $ResourceGroupName.ToLower() + "premstore"
$StdStorageAccname = $Storageprefix + $ResourceGroupName.ToLower() + "stdstore"
$StdBootdiagAccname = $Storageprefix + $ResourceGroupName.ToLower() + "stddiag"

$sub = Select-AzureRmSubscription -SubscriptionName $subscriptionName

#create resource groups
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $AzureDataCenter -Tag $tags

#Create storage accounts in environment resouce group
New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StdStorageAccname -Location $AzureDataCenter `
  -Kind Storage  -SkuName "Standard_LRS" -Tags $tags  
New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StdBootdiagAccname -Location $AzureDataCenter `
  -Kind Storage  -SkuName "Standard_LRS" -Tags $tags  
New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $PremStorageAccname -Location $AzureDataCenter `
 -SkuName "Premium_LRS" -Tags $tags 
$PremStorageKey = ((Get-AzureRmStorageAccountKey -Name $PremStorageAccname -ResourceGroup $ResourceGroupName) | select -First 1 -ExpandProperty value)
$PremContext  = New-AzureStorageContext -StorageAccountName $PremStorageAccname -StorageAccountKey $PremStorageKey
New-AzureStorageContainer -Context $PremContext -Name source   
New-AzureStorageContainer -Context $PremContext -Name vhds  
$StdStorageKey = ((Get-AzureRmStorageAccountKey -Name $StdStorageAccname -ResourceGroup $ResourceGroupName) | select -First 1 -ExpandProperty value)
$StdContext  = New-AzureStorageContext -StorageAccountName $StdStorageAccname -StorageAccountKey $StdStorageKey
New-AzureStorageContainer -Context $StdContext -Name source   
New-AzureStorageContainer -Context $StdContext -Name vhds

#Create access rules
New-AzureRmResource -ResourceName $SecurityGroupName -Location $AzureDataCenter  -ResourceGroupName $NetworkRGName `
 -ResourceType Microsoft.Network/networkSecurityGroups -Force -Tag $tags
$nsg = Get-AzureRmNetworkSecurityGroup -Name $SecurityGroupName -ResourceGroupName $NetworkRGName


$nsg | Add-AzureRmNetworkSecurityRuleConfig -Name  "BlockotherSubnets"  -Protocol "*"  -SourcePortRange "*"  -DestinationPortRange "*" `
  -SourceAddressPrefix "*"  -DestinationAddressPrefix $NetworkPrefix  -Access "Deny"  -Priority "1000"  -Direction "Outbound"
$nsg | Set-AzureRmNetworkSecurityGroup
$nsg | Add-AzureRmNetworkSecurityRuleConfig -Name  "AllowInternal"  -Protocol "*"  -SourcePortRange "*"  -DestinationPortRange "*" `
  -SourceAddressPrefix $SubnetAddressPrefix  -DestinationAddressPrefix $SubnetAddressPrefix  -Access "Allow"  -Priority "400" `
  -Direction "Outbound"
$nsg | Set-AzureRmNetworkSecurityGroup
$nsg | Add-AzureRmNetworkSecurityRuleConfig -Name  "AlllowZAHead"  -Protocol "*"  -SourcePortRange "*"  -DestinationPortRange "*" `
  -SourceAddressPrefix $SubnetAddressPrefix  -DestinationAddressPrefix "10.58.1.0/24"  -Access "Allow"  -Priority "600" `
  -Direction "Outbound"
$nsg | Set-AzureRmNetworkSecurityGroup



#Create Subnet
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $NetworkRGName -Name $vnetname
$routeTable = Get-AzureRmRouteTable -Name $RouteTableName -ResourceGroupName $NetworkRGName
$securityGroup = Get-AzureRmNetworkSecurityGroup -Name $SecurityGroupName -ResourceGroupName $NetworkRGName
Add-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $Subnetname -RouteTable $routeTable -AddressPrefix $SubnetAddressPrefix `
 -NetworkSecurityGroup $securityGroup
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
