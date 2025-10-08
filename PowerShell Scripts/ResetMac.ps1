Connect-VIServer -Server 10.1.101.xx 
Connect-CIServer -Server 10.1.101.xx -user administrator -password 8lu3m3`$a -wa 0

$civm = get-civapp "Banking Integration QA - 38.42 (ID4)" | Get-CIVM | sort

Foreach ($VM in $CIVm)

    {

    Write-Host "Resetting mac for $VM"

    $vm | Get-CINetworkAdapter | Set-CINetworkAdapter -ResetMACAddress

    Write-Host "Completed"

    }