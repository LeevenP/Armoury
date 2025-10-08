# Import MVMC modules - Microsoft Virtual machine Converter needs to be installed.
Import-Module "C:\Program Files\Microsoft Virtual Machine Converter\MvmcCmdlet.psd1"

# Convert First Server
# Convert Disk 1
#ConvertTo-MvmcVirtualHardDisk -SourceLiteralPath "D:\Azure_Export\Webserver1\Webserver1-Azure01\Webserver1-Azure01-disk1.vmdk" -DestinationLiteralPath "D:\Azure_Export\Webserver1\Exported\" -VhdType DynamicHardDisk -VhdFormat Vhd
# Convert Disk 2
#ConvertTo-MvmcVirtualHardDisk -SourceLiteralPath "D:\Azure_Export\Webserver1\Webserver1-Azure01\Webserver1-Azure01-disk2.vmdk" -DestinationLiteralPath "D:\Azure_Export\Webserver1\Exported" -VhdType DynamicHardDisk -VhdFormat Vhd

# Convert second server
# Convert Disk 1
ConvertTo-MvmcVirtualHardDisk -SourceLiteralPath "O:\Webserver1_36.08\Webserver1_36.08-disk1.vmdk" -DestinationLiteralPath "O:\vhd\Webserver1_36.08\Exported" -VhdType DynamicHardDisk -VhdFormat Vhd
# Convert Disk 2
ConvertTo-MvmcVirtualHardDisk -SourceLiteralPath "O:\Webserver1_36.08\Webserver1_36.08-disk2.vmdk" -DestinationLiteralPath "O:\vhd\Webserver1_36.08\Exported" -VhdType DynamicHardDisk -VhdFormat Vhd