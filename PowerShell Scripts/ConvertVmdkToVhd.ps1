# NEED TO RUN AS ADMIN


# Download and install Microsoft Virtual Machine Converter
# Import the module using the below
CLS
if (!(get-module MvmcCmdlet))
{
    Write-Host "Importing Microsoft Virtual Machine Converter PowerShell module" -ForegroundColor Yellow -NoNewline
    $MVMCPath = "C:\Program Files\Microsoft Virtual Machine Converter\MvmcCmdlet.psd1"
    Import-Module $MVMCPath
    Write-Host " --> Done" -ForegroundColor Green
}

# Conversion errors with: is not a supported disk database entry for the descriptor.
# VMDK file descriptor entries that Microsoft Converter doesn't recognise. To resolve the issue we need to remove these non-recognised entries:
# Download DSFOK tool and follow instructions from here: https://www.mysysadmintips.com/windows/servers/801-convertto-mvmcvirtualharddisk-the-entry-is-not-a-supported-disk-database-entry-for-the-descriptor

$vmdkSourceFolder  = "C:\tmp\LNP"
$vmdkSourceFile    = (Get-Childitem -Path $vmdkSourceFolder -Filter *.vmdk).FullName | where {$_ -like "*box-disk002.vmdk*"}
$vhdDestPath       = "C:\tmp\VHD"
$descriptorFile    = $vmdkSourceFolder + ($vmdkSourceFile.Split("\")[-1].replace(".vmdk",".txt"))
$newDescriptorFile = $descriptorFile.Split(".")[-2] + "_NEW.txt"

# Confirming VMDK file to convert
Write-Host "SOURCE VMDK TO CONVERT " -NoNewline -ForegroundColor Cyan
write-host "-->> " $vmdkSourceFile "<<--" -ForegroundColor Green
Write-Host ""

$confirm = Read-Host "Please confirm source VMDK to convert: (Y/N)"
if ($confirm -eq "Y")
{

    # After attempting ConvertTo-MvmcVirtualHardDisk command, if errors, then create the DESCRIPTOR.txt file (output from the command below): comment out the ddb.longContentID row, and ddb.fcd.uuid row (and any other rows that are mentioned in the error when running ConvertTo-MvmcVirtualHardDisk
    # Extract the database descriptor from the .VMDK file
    Write-host "Export DESCRIPTOR file from VMDK...." -ForegroundColor Yellow
    & C:\Users\leevenp\Desktop\DSfok\dsfok\dsfo.exe $vmdkSourceFile 512 1024 $descriptorFile
    Write-host "Done" -ForegroundColor Green
    Write-Host ""

    # Edit the Descriptor file and save to new TXT file
    $data          = Get-Content -Path $descriptorFile
    $itemsToRemove = @("ddb.toolsInstallType","ddb.fcd.uuid","ddb.uuid","ddb.comment")

    foreach ($item in $itemsToRemove)
    { 
        $outputFile = @()
        #Write-host "$item found in DESCRIPTOR file. Commenting them out..." -ForegroundColor Yellow
        foreach ($row in $data)
        {
            # Checking if DNS Name parameter exists in each row, and replaces it's IP with IPAddress parameter
            if ($row -match $item)
            {
                $row = "#" + $row
                $outputFile += $row
            }
            else
            {
                $outputFile += $row
            }
        }
        $outputFile | Out-File $newDescriptorFile -Force default
        $data = Get-Content -Path $newDescriptorFile

    }
    write-host ""

    # Attempt the ConvertTo-MvmcVirtualHardDisk command again. If more errors, then go back and comment any other rows that are mentioned in the error when running ConvertTo-MvmcVirtualHardDisk
    # Import the updated descriptor.txt file back into the .VMDK
    Write-host "Import the updated DESCRIPTOR file back into VMDK...." -ForegroundColor Yellow
    & C:\Users\leevenp\Desktop\DSfok\dsfok\dsfi.exe $vmdkSourceFile 512 1024 $newDescriptorFile
    Write-host "Done" -ForegroundColor Green
    Write-Host ""

    # Re-run ConvertTo-MvmcVirtualHardDisk --> Convert VMDK to a Fixed .VHD file
    Write-host "Converting VMDK to VHD. Please wait...." -ForegroundColor Yellow
    $task = ConvertTo-MvmcVirtualHardDisk -SourceLiteralPath $vmdkSourceFile -DestinationLiteralPath $vhdDestPath -VhdType FixedHardDisk -VhdFormat Vhd
    Write-Host "Done" -ForegroundColor Green
    write-host ""

    Write-host "DESTINATION VHD " -NoNewline -ForegroundColor Cyan
    Write-Host "-->>" $task.Destination.FullName "<<--" -ForegroundColor Green
    Write-Host ""

    $answer = Read-Host "Please confirm to delete the source VMDK, and DESCRIPTOR files: (Y/N)"
    if ($answer -eq "Y")
    {
        Remove-Item -Path $DescriptorFile -Force
        write-host $descriptorFile "--> Deleted" -ForegroundColor Red
        Remove-Item -Path $newDescriptorFile -Force
        Write-Host $newDescriptorFile "--> Deleted" -ForegroundColor Red
        Remove-Item -Path $vmdkSourceFile -Force
        Write-Host $vmdkSourceFile "--> Deleted" -ForegroundColor Red
        Write-Host "Done" -ForegroundColor Green
        write-host ""
    }
    else
    {
        Write-Host "Skipping delete..." -ForegroundColor Red
        Write-Host ""
    }
}
else
{
    Write-Host ""
    Write-Host "Nothing converted. Please update script with correct VMDK source file" -ForegroundColor Magenta
    Write-Host ""
}