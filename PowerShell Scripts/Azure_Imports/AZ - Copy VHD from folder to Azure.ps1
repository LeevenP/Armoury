if (!(get-Module -listavailable | ?{$_.name -like "AzureRM"}))
{
	Install-Module AzureRM
}
Import-Module AzureRM

Login-AzureRmAccount

$subscriptionName = "your subscription name"

$sub = Select-AzureRmSubscription -SubscriptionName $subscriptionName

$srcStorageAccount = "yourstorageaccountname"
$srcStorageKey = "insert key here"
#Define the destination Storage Account. This is where the vhd will be copied to. Again, the private key can be acquired from the azure portal

$srcContext = New-AzureStorageContext `
    -StorageAccountName $srcStorageAccount `
    -StorageAccountKey $srcStorageKey 

set-azureRmCurrentStorageAccount -context $srcContext


$filepath = "insert local path here"   
$resourceGroup = "Scalability"
$containerUri = "insert container uri here"

$filelist = Get-ChildItem $filepath -file -Depth 1 -Filter “*.vhd”  
ForEach ($file in $filelist){
$Localpath = $file.fullname
Write-Host "Initiating copy of $LocalPath to Azure" -ForeGroundColor Cyan
Add-AzureRmVhd -ResourceGroupName $resourceGroup -Destination "$containerUri\$($file.name)" -LocalFilePath $Localpath -NumberOfUploaderThreads 16 -OverWrite
#write-host $containerUri"/"$_.name
write-host "Finished $($file.name)" -Foregroundcolor Green}
