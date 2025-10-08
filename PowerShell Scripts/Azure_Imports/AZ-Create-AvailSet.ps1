


param
(
    $subscriptionName = "insert subscription name here",
    $ResourceGroupName = "BalanceBroker",
    $AzureDataCenter = "West Europe"
)
$sub = Select-AzureRmSubscription -SubscriptionName $subscriptionName


New-AzureRmAvailabilitySet -ResourceGroupName "$ResourceGroupName" -Name $ResourceGroupName"LNPAvailSet" -Location $AzureDataCenter
#New-AzureRmAvailabilitySet -ResourceGroupName "$ResourceGroupName" -Name $ResourceGroupName"AccountAvailSet" -Location $AzureDataCenter
#New-AzureRmAvailabilitySet -ResourceGroupName "$ResourceGroupName" -Name $ResourceGroupName"OpertorAvailSet" -Location $AzureDataCenter
#New-AzureRmAvailabilitySet -ResourceGroupName "$ResourceGroupName" -Name $ResourceGroupName"RouterAvailSet" -Location $AzureDataCenter
#New-AzureRmAvailabilitySet -ResourceGroupName "$ResourceGroupName" -Name $ResourceGroupName"VanguardAvailSet" -Location $AzureDataCenter
#New-AzureRmAvailabilitySet -ResourceGroupName "$ResourceGroupName" -Name $ResourceGroupName"XMANAvailSet" -Location $AzureDataCenter 
#New-AzureRmAvailabilitySet -ResourceGroupName "$ResourceGroupName" -Name $ResourceGroupName"CasinoAvailSet" -Location $AzureDataCenter 