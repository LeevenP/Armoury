Connect-VIServer 10.1.101.180

#region - Single VM Export from vSphere

$vm           = Get-VM "APP1_2016 (bd1939dc*"
$format       = "OVA"
$targetFolder = Get-Item "\\destinationfolder\share\box"

$vmName = ($vm.name).Split(" ")[0]
$vm | Export-VM -Destination $targetFolder -Format $format -Name $vmName -Force

#endregion



#region - Multi VM export from vSphere

$vmFolder     = get-folder | where {$_.Name -like "Landbased US GM LUS1 - 8.00 IBM (TC10) (b52b5c1b-1a16-41a0-a658-b3a106ae25fd)"}
$vms          = get-folder $vmFolder | Get-VM | Where-Object {$_.Name -notlike "shadow-*" -and $_.Name -like "CasinoAS1*" -or $_.Name -like "Webserver4*"} | Sort-Object
$exportFormat = "OVF"
$outputFolder = Get-Item "Q:\Export\Landbased\LUS"

foreach ($vm in $vms)
{
    $vmName = ($vm.name).Split(" ")[0]
    write-host "Please wait. Currently exporting:" $vmName -foregroundcolor Yellow
    $vm | Export-VM -Destination $outputFolder -Format $exportFormat -Name $vmName -Force

    write-host ""
}

#endregion 
