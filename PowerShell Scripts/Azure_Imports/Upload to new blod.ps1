#Login-AzureRmAccount

$subscriptionName = "Enterprise Dev/Test"


$sub = Select-AzureRmSubscription -SubscriptionName $subscriptionName


$srcStorageAccount = "scalabilitystd"
$srcStorageKey = "insert storage key here"
#Define the destination Storage Account. This is where the vhd will be copied to. Again, the private key can be acquired from the azure portal

$srcContext = New-AzureStorageContext `
    -StorageAccountName $srcStorageAccount `
    -StorageAccountKey $srcStorageKey 

set-azureRmCurrentStorageAccount -context $srcContext

$filepath = "o:\VHD\Webserver1_36.08_Disk1.vhd"   
$subscriptionName = "Enterprise Dev/Test"
$resourceGroup = "Scalability"
$containerUri = "https://scalabilitystd.blob.core.windows.net/gm-3608-import"
$filename = split-path $filepath -leaf -resolve

# Add-AzureRmVhd -ResourceGroupName $resourceGroup -Destination "$containerUri/$filename" -LocalFilePath $filepath -NumberOfUploaderThreads 16 -OverWrite 
# Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/vhdupload/Webserver1-Disk1.vhd" -LocalFilePath "D:\Export\Webserver1\Webserver1-disk1.vhd" -NumberOfUploaderThreads 16 -OverWrite
# Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/vhdupload/Webserver1-Disk2.vhd" -LocalFilePath "D:\Export\Webserver1\Webserver1-disk2.vhd" -NumberOfUploaderThreads 16 -OverWrite
# Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/vhdupload/Webserver2-Disk1.vhd" -LocalFilePath "D:\Export\Webserver2\Webserver2-disk1.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/HorizonAS1_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\HorizonAS1_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/HorizonAS1_36.08_Disk1.vhd" -LocalFilePath "o:\VHD\HorizonAS1_36.08_Disk1.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/MetricsAS1_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\MetricsAS1_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/MetricsAS1_36.08_Disk1.vhd" -LocalFilePath "o:\VHD\MetricsAS1_36.08_Disk1.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/MPPGS1_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\MPPGS1_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/MPPGS2_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\MPPGS2_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/MPVGS1_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\MPVGS1_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/PCMDB1_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\PCMDB1_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/PCMDB1_36.08_Disk1.vhd" -LocalFilePath "o:\VHD\PCMDB1_36.08_Disk1.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/PTSDB1_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\PTSDB1_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/PTSDB1_36.08_Disk1.vhd" -LocalFilePath "o:\VHD\PTSDB1_36.08_Disk1.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/PTSDB1_36.08_Disk2.vhd" -LocalFilePath "o:\VHD\PTSDB1_36.08_Disk2.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/RaptorGS1_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\RaptorGS1_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/RaptorGS2_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\RaptorGS2_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/RaptorGS3_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\RaptorGS3_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/RaptorGS4_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\RaptorGS4_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/RaptorGS5_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\RaptorGS5_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/RaptorGS6_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\RaptorGS6_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/RaptorGS7_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\RaptorGS7_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/RaptorGS8_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\RaptorGS8_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/RaptorGS9_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\RaptorGS9_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/RaptorGS10_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\RaptorGS10_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/SSISBI01_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\SSISBI01_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/SSISBI01_36.08_Disk1.vhd" -LocalFilePath "o:\VHD\SSISBI01_36.08_Disk1.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/SwiftWeb_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\SwiftWeb_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/Swiftweb_36.08_Disk1.vhd" -LocalFilePath "o:\VHD\Swiftweb_36.08_Disk1.vhd" -NumberOfUploaderThreads 16 -OverWrite

Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/Webserver1_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\Webserver1_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/Webserver1_36.08_Disk1.vhd" -LocalFilePath "o:\VHD\Webserver1_36.08_Disk1.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/Webserver2_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\Webserver2_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/Webserver2_36.08_Disk1.vhd" -LocalFilePath "o:\VHD\Webserver2_36.08_Disk1.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/Webserver3_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\Webserver3_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/Webserver3_36.08_Disk1.vhd" -LocalFilePath "o:\VHD\Webserver3_36.08_Disk1.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/Webserver4_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\Webserver4_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/Webserver4_36.08_Disk1.vhd" -LocalFilePath "o:\VHD\Webserver4_36.08_Disk1.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/Webserver8_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\Webserver8_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/Webserver8_36.08_Disk1.vhd" -LocalFilePath "o:\VHD\Webserver8_36.08_Disk1.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/Webserver9_36.08_Disk0.vhd" -LocalFilePath "o:\VHD\Webserver9_36.08_Disk0.vhd" -NumberOfUploaderThreads 16 -OverWrite
Add-AzureRmVhd -ResourceGroupName Scalability -Destination "https://scalabilitystd.blob.core.windows.net/gm3608/Webserver9_36.08_Disk1.vhd" -LocalFilePath "o:\VHD\Webserver9_36.08_Disk1.vhd" -NumberOfUploaderThreads 16 -OverWrite