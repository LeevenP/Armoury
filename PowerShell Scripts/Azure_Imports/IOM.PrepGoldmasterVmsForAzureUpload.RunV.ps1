<#
.Synopsis
    Script to prep VMware VMs for Azure upload

.DESCRIPTION
    This script will prompt a menu to perform any of the following:
    - import a Goldmaster template VM, into vCenter
    - Power on the imported VM/s
    - Power off the imported VM/s
    - Uninstall VMinfo Service from the imported VM/s
    - Uninstall VMware Tools from the imported VM/s
    - Convert VMware virtual disks (VMDK's) to Microsoft Fixed disks (VHD's)
    
    Requirements: 
    - Run script As Administrator
    
    Software Requirements:
    - PowerShell 4.0 or higher
    - PowerCLI 6 R2 or higher
    - Microsoft Virtual Machine Converter 3.0 or higher 
        - https://www.microsoft.com/en-za/download/details.aspx?id=42497
    - Microsoft Azure PowerShell Command Line Tools 
        - https://azure.microsoft.com/en-us/downloads/?fb=en-us

.EXAMPLE
    C:\SCRIPTS\Start Powershell -verb runAs Azure-Prep.Run.ps1

Team:		IT Environments Team - Environment Management (ITEnvironments-EM@derivco.com)
Date:		DECEMBER 2016
Version:    1.0

#>

#region FUNCTIONS

Function Script-Title
{
    # SETS SCRIPT TITLE DURING RUNTIME
    cls
    $windowTitle = "IT ENVIRONMENTS - Prepare Goldmaster VMware VMs for Azure Upload"
    $host.ui.RawUI.WindowTitle = $windowTitle
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Yellow `r
    Write-Host "  $windowTitle" -ForegroundColor Yellow `r
    Write-Host "======================================================================" -ForegroundColor Yellow `r
    Write-Host ""
}

Function Connect-ManagementServers
{
    # CONNECTS TO VSPHERE MANAGEMENT SERVERS
    Connect-VIServer -Server $IOBVC -User $VCuser -Password $VCpass -wa 0 | out-null
    Write-Host "IOB vCenter Server connected: " $IOBVC -ForegroundColor Cyan `r
    Write-Host ""
}

Function Disconnect-ManagementServers
{
    # DISCONNECT MANAGEMENT SERVERS

	Write-Host ""
    Disconnect-VIServer -Server $IOBVC -wa 0 -Confirm:$false
    Write-Host "IOB vCenter Server disconnected: " $IOBVC -ForegroundColor Cyan `r

}

Function Add-ManagementModules
{
    # ADD VMWARE VCLOUD SNAPIN IF NOT ALREADY AVAILABLE (Requires PowerCLI)
    if (-not (Get-Module vmware.vimautomation.cloud -ErrorAction SilentlyContinue)) {
        Import-Module vmware.vimautomation.cloud
    }
}

function Show-Menu
{
    param($List,$title)
    cls
    Script-Title
    write-host ""
    Write-Host "=============== $Title ===============" -ForegroundColor Yellow
    write-host ""
#    $i = 0
    $i = 1

    Foreach ($global:item in @($List))
        {
        Write-Host $i ")" `t -ForegroundColor Green -NoNewline
        Write-Host $item -ForegroundColor Yellow
        $i++
        }
    
    if ($Title -eq "CHOOSE VM TEMPLATE TO IMPORT TO vCENTER" -or $Title -eq "CHOOSE VM to EXPORT to OVF for AZURE" -or $Title -eq "SELECT VMDK TO CONVERT")
        {
        write-host ""
        write-host "A )" `t  -foregroundcolor Green -NoNewLine
        write-host "Import All" -ForegroundColor Yellow
        }

    write-host ""
    write-host "Q )" `t  -foregroundcolor Green -NoNewLine
    write-host "QUIT" -ForegroundColor Yellow
    write-host ""
#    $global:Choice = Read-Host "Please make your selection: (0 - $($i - 1))"
    $global:Choice = Read-Host "Please make your selection: (1 - $($i - 1))"
    Return $Choice

} 

function Show-MainMenu
{
    do
    {
        [string]$title = "MAIN MENU"
        $list = @("Import GM template VM to vCenter","Power on VM/s","Remove VMInfoService","Remove VMware Tools","Power off VM/s","Export VM/s to OVF","Delete VMs in Azure Imports folder in vCenter","Convert VMware VMDK to Microsoft VHD","Upload VHD to Azure")

        switch ( Show-Menu -List $List -title $title )
        {
            1 { Import-VMFromOVA }
            2 { PowerOn-VMs }
            3 { Remove-VMInfo }
            4 { Remove-VMwareTools }
            5 { PowerOff-VMs }
            6 { Export-VMToOVF }
            7 { Cleanup-VMsforAzure }
            8 { Convert-VMDKtoVHD }
            9 { UploadTo-Azure }
    
        }
    }
    while ($choice -ne 'q')
    write-host ""
    Write-Host "Quitting..." -ForegroundColor Red
    sleep 1
    Break
}

Function Import-VMFromOVA
{
    write-host ""
    Write-Host "Getting available GM versions. Please wait..." -ForegroundColor Yellow
    sleep 1

    $List = @((Get-ChildItem $Source).Name | sort -Descending)
    [string]$title = "GOLDMASTER VERSIONS"

    Switch (Show-Menu -List $List -title $title )
    {
        $choice { 
                    if ($choice -eq 'Q') { write-host "Quitting..." -ForegroundColor Yellowta; Show-MainMenu}
                    $ver = $list[$choice - 1]

                    write-host ""
                    Write-Host "Getting VMs for $ver. Please wait..." -ForegroundColor Yellow
                    sleep 1

                    $list = @((Get-childItem -File ($Source + $ver) -recurse | where {$_.name -like "*.ovf"-or $_.Name -like "*ova*" }).Name | sort )
                    [string]$title = "CHOOSE VM TEMPLATE TO IMPORT TO vCENTER"
                   
                    switch ( Show-Menu -List $List -title $title)
                    {
                        $choice { 
                                if ($choice -eq 'q') {write-host "Quitting..." -ForegroundColor Red; Show-MainMenu}
                                $ALL = if  ($Choice -eq 'a'){"true"}   
                                if (!($ALL)){$vm = $List[$choice - 1]}

                                if ($vm -like "*.ova" )
                                { $vmName = $vm -replace ".ova" , "" ; $ova = $true}
                                if ($vm -like "*.ovf" )
                                { $vmName = $vm -replace ".ovf" , "" ; $ovf = $true}

                                if ($All){
                                write-host ""
                                write-host "VM template to import  = " -foregroundcolor Green -nonewline
                                write-host "You have selected to Import all Vm's" -ForegroundColor Yellow 
                                }
                                else {    
                                write-host ""
                                write-host "VM template to import  = " -foregroundcolor Green -nonewline
                                write-host $vmName -ForegroundColor Yellow 
                                }
                                write-host "Target folder in VC    = " -foregroundcolor Green -nonewline
                                write-host $Folder -ForegroundColor Yellow
                                write-host ""

                                if ($ALL) {$confirm = Read-Host "Please confirm the import of ALL VM's to the target folder: (Y/N)"}
                                    else {$confirm = Read-Host "Please confirm the import of VM to the folder: (Y/N)"}

                    if ($Choice -eq 'a') 
                        {
                        $count = 0
                        $x = 1
                        $filePath = $Source + $ver + "\"
                        $total = (Get-childItem -File $filePath -recurse | ? {$_.name -like "*.ovf" -or $_.Name -like "*ova*"}).count
                        $Formate = Get-childItem -File $filePath -recurse | ? {$_.name -like "*.ovf" -or $_.Name -like "*ova*"} | sort | select FullName, Name
                        if ($Formate.name[0] -like "*.ova"){$Rmv = ".ova"}
                        if ($Formate.name[0] -like "*.ovf"){$Rmv = ".ovf"}
                        write-host ""
                        cls

                        Do
                            {
                            if ($count -gt $Total){$count = 0; $x = 1}
                                foreach ($vm in $Formate[$count])
                                    {
                                    #$filePath = ($Source + $ver)
                                    if ($x -eq $Total)
                                        {
                                        write-host "[$x of $Total]" -foregroundcolor Cyan
	                                    $filePath = $vm.FullName
	                                    $vmname = ($vm.Name -replace $Rmv ,"")
                                        Write-Host "-->" $vmname "importing to vCenter" -ForegroundColor Yellow -NoNewLine
                                        $importTask1 = Import-VApp -Source $filePath -Name $vmname -VMHost $targetVMHost -Datastore "IOBTINTRI02"  -DiskStorageFormat Thin -RunAsync -ev err #| out-null
                                        if ($err){Write-host "$vm Has already been exported" -ForegroundColor Gray}
                                        #Write-Host " --> Imports completed." -ForegroundColor Green
                                        }
                                        Else
                                        {
                                         write-host "[$x of $Total]" -foregroundcolor Cyan
	                                     $filePath = $vm.FullName
	                                     $vmname = ($vm.Name -replace $Rmv ,"")
                                         Write-Host "-->" $vmname "importing to vCenter" -ForegroundColor Yellow
                                         $importTask1 = Import-VApp -Source $filePath -Name $vmname -VMHost $targetVMHost -Datastore "IOBTINTRI02"  -DiskStorageFormat Thin -RunAsync -ev err #| out-null
                                         if ($err){Write-host "$vm Has already been exported" -ForegroundColor Gray}
                                         $count++
                                         $x++
                                         Sleep 5
                                            Foreach ($vm1 in $Formate[$count])
                                                {
                                                write-host "[$x of $Total]" -foregroundcolor Cyan
	                                            $filePath = $vm1.FullName
	                                            $vmname = ($vm1.Name -replace $Rmv ,"")
                                                Write-Host "-->" $vmname "importing to vCenter" -ForegroundColor Yellow
                                                $importTask2 = Import-VApp -Source $filePath -Name $vmname -VMHost $targetVMHost -Datastore "IOBTINTRI02"  -DiskStorageFormat Thin -RunAsync -ev err #| out-null
                                                #Write-Host " --> Imports completed." -ForegroundColor Green
                                                if ($err){Write-host "$vm Has already been exported" -ForegroundColor Gray}
                                                $x++
                                                $count++
                                                }
                                        }
                                    Write-Host ""
                                    while ($importTask1.State -eq "Running" -or $importTask2.State -eq "Running") 
                                        {                       
                                        start-sleep 5
                                        write-host -NoNewline  `r ($vm.Name -replace $Rmv,"") $importTask1.PercentComplete"% Completed, " -foregroundcolor Gray
                                        if ($vm1) {Write-host -NoNewline  ($vm1.Name -replace $Rmv ,"") $importTask2.PercentComplete"% Completed." `r -foregroundcolor Gray}
                                        }
                                    Write-Host ""
                                    Write-Host ""
                                    }
    $VMCount = (Get-VM "*$ver").count
                            }
Until ($VMCount -eq $Total)
}
#Moving VMs into the Azure Folder
if ($Choice -eq 'a') {
$Imports = Get-VM "*$ver"
$Imports | foreach  {
write-host "Moving $_ to $Folder folder"  -ForegroundColor Yellow -nonewline
Move-VM -VM $_ -Destination $Folder | out-null
write-host " --> Complete"-ForegroundColor Green
    }
}
                                
                               if ($confirm -eq 'n')
                                {
                                    write-host "Going back..." -ForegroundColor Yellow
                                    sleep 1
                                }
                                else
                                {
                                    if ($ovf) {$filePath = $Source + $ver + "\" + $vmName + "\" + $vm}
                                    if ($ova) {$filePath = $Source + $ver + "\" + $vm}
                                        
                                    write-host ""
                                    Write-Host $vmName "now importing to vCenter. Please wait..." -ForegroundColor Yellow
                                    $importTask = Import-VApp -Source $filePath -Name $vmName -VMHost $targetVMHost -Datastore $targetDatastore -DiskStorageFormat Thin -RunAsync #| out-null
                                        
                                    while ($importTask.State -eq "Running") 
                                    {                       
                                        start-sleep 120
                                        write-host "--> still importing. Please wait..." -foregroundcolor Yellow
                                    }
                                        
                                    Get-VM $vmName | Move-VM -Destination $Folder | out-null
                                    Write-Host "--> Import completed." -ForegroundColor Green
                                    sleep 5
                                }


                                }  #end Choice
                    
                    } #end Switch 2

                }
    } #end Switch 1
}

Function PowerOn-VMs
{
    [string]$title = "POWER ON VMs FOR AZURE PREP"
    write-host ""
    Write-Host "============ $Title ============" -ForegroundColor Yellow
    write-host ""

    $VMs = (Get-Folder $folder | Get-VM) | where {$_.PowerState -eq "PoweredOff"} | sort
    foreach ($vm in $VMs) { write-host $vm.name `t-`t   $vm.powerstate -ForegroundColor Yellow }

    if ($VMs.count -ne 0)
    {
        write-host ""
        $Confirm = Read-Host "Please confirm to power ON the above VM/s: (Y/N)"

        if ($confirm -eq 'y')
        {
            write-host ""
            Write-Host "--> Powering ON"$VMs.count"VM/s. Please wait..." -ForegroundColor Yellow
            write-host ""

            ForEach ($vm in $VMs) 
            {
                write-host $vm -ForegroundColor Yellow
                Start-VM $vm -ErrorAction SilentlyContinue -RunAsync | Out-Null
                do 
                {
                    Write-Host "--> powering on. Please wait..." -ForegroundColor Yellow
                    sleep 5
                }
                until ( (get-vm $vm).powerState -eq "PoweredOn" )

                Write-Host "--> powered on successfully." -ForegroundColor Green
                write-host ""
                sleep 5
            }
        }
        else
        {
            write-host "Going back..." -ForegroundColor Yellow
            sleep 1
        }
    }
    else
    {
        Write-Host "All VM/s already powered ON, or no VMs available in source folder" -ForegroundColor Magenta
        sleep 2
    }
}

Function Remove-VMInfo
{
    [string]$title = "REMOVE VMINFOSERVICE from VMs for AZURE PREP"
    write-host ""
    Write-Host "============ $Title ============" -ForegroundColor Yellow
    write-host ""

    $VMs = (Get-Folder $folder | Get-VM) | where {$_.PowerState -ne "PoweredOff"} | sort
    foreach ($vm in $VMs) { write-host $vm.name `t-`t   $vm.powerstate -ForegroundColor Yellow }
    
    if ($VMs.count -ne 0)
    {

        write-host ""
        $Confirm = Read-Host "Please confirm to Remove VMInfoService from the VM/s: (Y/N)"

        if ($confirm -eq 'y')
        {

            $scriptblock = {
                write-host "--> Searching for VMInfoService..." -ForegroundColor Yellow
                $svc = get-service "VMInfoService" -ErrorAction SilentlyContinue
                if ($svc)
                {
                    write-host "--> VMInfoService found..." -ForegroundColor Green

                    if ($svc.Status -eq "Running")
                    {
                        Write-Host "--> VMInfoService stopping. Please wait..." -ForegroundColor Yellow
                        $svc | Stop-Service
                    }
                    else
                    {
                        Write-Host "--> VMInfoService already stopped..." -ForegroundColor Yellow
                    }
                    sc.exe delete $svc.Name | Out-Null
                    Write-Host "--> VMInfoService deleted..." -ForegroundColor Green
                }
                else
                {
                    Write-Host "--> VMInfoService cannot be found. Skipping" -ForegroundColor Magenta
                    sleep 2
                }

                Write-Host ""
            }

            $VMs = Get-Folder $folder | Get-VM | sort
            foreach ($vm in $VMs)
            {
                if ($vm.powerState -eq "poweredOn")
                {
            
                    if ($VM.Guest.OSFullName -like "*Microsoft*")
                    {
                        write-host $vm "--> removing VMInfoService. Please wait..." -ForegroundColor Yellow 
                        $removeVMinfo = Invoke-VMScript -VM $vm -ScriptType Powershell -ScriptText $scriptblock -GuestCredential $guestCreds
                        Write-Host "--> VMInfoService deleted..." -ForegroundColor Green
                    }
                    else
                    {
                        write-host $vm.Name "--> is not Microsoft. Skipping..." -ForegroundColor Magenta
                        sleep 2
                    }
                }
                else
                {
                    write-host $VM.Name "is not powered on. Skipping..." -ForegroundColor Magenta
                }
            } #end Foreach
        }
        else
        {
            write-host "Going back..." -ForegroundColor Yellow
            sleep 1

        }
    }
    else
    {
        write-host "No VMs are powered on..." -ForegroundColor Magenta
        sleep 2
    }
}

Function Remove-VMwareTools
{
    [string]$title = "REMOVE VMWARE TOOLS from VMs for AZURE PREP"
    write-host ""
    Write-Host "============ $Title ============" -ForegroundColor Yellow
    write-host ""

    $VMs = (Get-Folder $folder | Get-VM) | where {$_.PowerState -ne "PoweredOff"} | sort
    foreach ($vm in $VMs) { write-host $vm.name `t-`t   $vm.powerstate -ForegroundColor Yellow }
   
    if ($VMs.count -ne 0)
    {

        write-host ""
        $Confirm = Read-Host "Please confirm to Remove VMware Tools from the VM/s: (Y/N)"

        if ($confirm -eq 'y')
        {


            $scriptBlock = {
            write-host "--> Searching for VMware Tools..." -ForegroundColor Yellow
            $app = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "VMware Tools" }
            if ($app)
            {
                write-host "--> VMware Tools found..." -ForegroundColor Green
                write-host "--> VMware Tools uninstalling. Please wait..." -ForegroundColor Yellow
                $AppGUID = $app.properties["IdentifyingNumber"].value.toString()
                MsiExec.exe /q/x $AppGUID REMOVE=ALL
                write-host "--> VMware Tools removed. Please shut down server..." -ForegroundColor Green
        
                #get-civm | .ExtensionData.Undeploy_Task(“force”) 
            }
            else
            {
                Write-Host "--> VMware Tools cannot be found. Skipping..." -ForegroundColor Magenta
                sleep 2
            }
    
            Write-Host ""
            }

            $VMs = Get-Folder $folder | Get-VM | sort
            foreach ($vm in $VMs)
            {
                if ($vm.powerState -eq "poweredOn")
                {
                    if ( ($VM.Guest.OSFullName -like "*Microsoft*") -and ($vm.Guest.ExtensionData.ToolsRunningStatus -eq "guestToolsRunning") )
                    {
                        write-host $vm "--> removing VMware Tools. Please wait..." -ForegroundColor Yellow
            
                        while ( ((get-vm $vm).Guest.ExtensionData.toolsStatus -ne "toolsNotInstalled") -and ($vm.Guest.ExtensionData.ToolsRunningStatus -ne "guestToolsNotRunning") )
                        {                       
                            $removeVMinfo = Invoke-VMScript -VM $vm -ScriptType Powershell -ScriptText $scriptblock -GuestCredential $guestCreds -ErrorAction SilentlyContinue
                            write-host "--> Still removing. Please wait..." -foregroundcolor Yellow
                            start-sleep 15
                        }
                        Write-Host "--> VMware Tools removed." -ForegroundColor Green
                        write-host ""
            
                    }
                    else
                    {
                        write-host $vm.Name "--> is not Microsoft. Skipping..." -ForegroundColor Magenta
                        sleep 2
                    }
                }
                else
                {
                    write-host $VM.Name "is not powered on. Skipping..." -ForegroundColor Magenta
                    sleep 2
                }
            } #end Foreach
        }
        else
        {
            Write-Host "Going back..." -ForegroundColor Yellow
            sleep 1
        }
    }
    else
    {
        write-host "No VMs are powered on..." -ForegroundColor Magenta
        sleep 2
    }
}

Function PowerOff-VMs
{
    
    [string]$title = "POWER OFF VMs FOR AZURE PREP"
    write-host ""
    Write-Host "============ $Title ============" -ForegroundColor Yellow
    write-host ""

    $VMs = (Get-Folder $folder | Get-VM) | where {$_.PowerState -eq "PoweredOn"} | sort
    foreach ($vm in $VMs) { write-host $vm.name `t-`t   $vm.powerstate -ForegroundColor Yellow }

    if ($VMs.count -ne 0)
    {
        write-host ""
        $Confirm = Read-Host "Please confirm to power OFF the above VM/s: (Y/N)"

        if ($confirm -eq 'y')    
        {
            write-host ""
            Write-Host "--> Powering OFF"$vms.count"VM/s. Please wait..." -ForegroundColor Yellow
            write-host ""

            ForEach ($vm in $VMs) 
            {
                write-host $vm -ForegroundColor Yellow
                Stop-VM $vm -ErrorAction SilentlyContinue -RunAsync -Confirm:$false | Out-Null
            
                do 
                {
                    Write-Host "--> powering off. Please wait..." -ForegroundColor Yellow
                    sleep 5
                }
                until ( (get-vm $vm).powerState -eq "PoweredOff" )

                Write-Host "--> powered off successfully." -ForegroundColor Green
                write-host ""
                sleep 5
            }
        }
        else
        {
            Write-Host "Going back..." -ForegroundColor Yellow
            sleep 1
        }
    }
    else
    {
        write-host "All VMs already off, or no VMs available in source folder..." -ForegroundColor Magenta
        sleep 2
    }
}

Function Export-VMToOVF
{
    $List = @((Get-Folder $folder | get-vm | where {$_.powerState -eq "PoweredOff"}).Name | sort)
    [string]$title = "CHOOSE VM to EXPORT to OVF for AZURE"
      
    Switch (Show-Menu -List $List -title $title )
    {
            
        $choice {
                if ($choice -eq 'Q') { write-host "Quitting..." -ForegroundColor Red ; Show-MainMenu}
                      
                write-host ""
                write-host "Selection     =  " -ForegroundColor Green -NoNewline
                Write-Host $choice -ForegroundColor Yellow
                
                $ALL = if  ($Choice -eq 'a'){"true"}   
                if (!($ALL)){$vm = Get-VM $List[$choice - 1]}    
                $timeStamp = (get-date -Format s).Split("T")[0]
                $destFolder = New-Item -Path $destPath -name ("OVF_Export_" + $timeStamp) -ItemType Directory -ea SilentlyContinue
                if (!$destFolder)
                    {
                    $Foldername = ("\" + "Export_" + $timeStamp)
                    $destFolder = get-item ($destPath + $Foldername)
                    }    

                if ($all){
                    write-host ""
                    write-host "VM to export  =  " -foregroundcolor Green -nonewline
                    write-host "You have selected to Export all Vm's" -ForegroundColor Yellow 
                    }
                    else {
                         write-host ""
                         write-host "VM to export  =  " -foregroundcolor Green -nonewline
                         write-host $vm.Name -ForegroundColor Yellow 
                         }
                write-host "Target folder =  " -foregroundcolor Green -nonewline
                write-host $destFolder -ForegroundColor Yellow
                write-host ""

                $confirm = Read-Host "Please confirm the export of the VM above: (Y/N)"

                if ($confirm -eq 'n')
                {
                    write-host "Going back..." -ForegroundColor Yellow
                    Show-MainMenu
                    sleep 1
                }
                elseif ($vm)
                {
                    write-host ""
                    Write-Host $vm.Name "now exporting to OVF. Please wait..." -ForegroundColor Yellow
                    $exportTask = Export-VM -Destination $destFolder -VM $vm -Name $vm.Name -RunAsync -ErrorAction SilentlyContinue
                                        
                    while ($exportTask.State -eq "Running") 
                    {                       
                        start-sleep 120
                        write-host "--> still exporting. Please wait..." -foregroundcolor Yellow
                    }
                                        
                    # Deletes non-VMDK files
                    gci $destFolder -File -Recurse | where {$_.Name -notmatch ".vmdk"} | Remove-Item -Force
                    
                    Write-Host "--> Export completed." -ForegroundColor Green
                    sleep 5
                }

                if ($Choice -eq 'a') 
                    {
                        $count = 0
                        $x = 1
                        $ExportVMs = (Get-Folder $folder | get-vm | ? {$_.powerState -eq "PoweredOff"}).Name | sort 
                        $Total = ($ExportVMs).count 

                        Do
                            {
                            write-host ""
                            if ($count -gt $Total){$count = 0; $x = 1}
                                foreach ($vm in $ExportVMs[$count])
                                    {
                                    if ($x -eq $Total)
                                        {
                                        write-host "[$x of $Total]" -foregroundcolor Cyan	                                    
                                        Write-Host "-->" $vm "Exporting to" $folder -ForegroundColor Yellow -NoNewLine
                                        $exportTask1 = Export-VM -Destination $destFolder -VM $vm -Name $vm -RunAsync -ErrorAction SilentlyContinue
                                        if ($err){Write-host "$vm Has already been exported" -ForegroundColor Gray}
                                        #Write-Host " --> Imports completed." -ForegroundColor Green
                                        }
                                        Else
                                        {
                                         write-host "[$x of $Total]" -foregroundcolor Cyan
                                         Write-Host "-->" $vm "Exporting to" $folder -ForegroundColor Yellow
                                         $exportTask1 = Export-VM -Destination $destFolder -VM $vm -Name $vm -RunAsync -Force -ErrorAction SilentlyContinue
                                         if ($err){Write-host "$vm Has already been exported" -ForegroundColor Gray}
                                         $count++
                                         $x++
                                         Sleep 5
                                            Foreach ($vm1 in $ExportVMs[$count])
                                                {
                                                write-host "[$x of $Total]" -foregroundcolor Cyan
                                                Write-Host "-->" $vm1 "Exporting to" $folder -ForegroundColor Yellow
                                                $exportTask2 = Export-VM -Destination $destFolder -VM $vm1 -Name $vm1 -RunAsync -ErrorAction SilentlyContinue
                                                #Write-Host " --> Imports completed." -ForegroundColor Green
                                                if ($err){Write-host "$vm Has already been exported" -ForegroundColor Gray}
                                                $x++
                                                $count++
                                                }
                                        }
                                    Write-Host ""
                                    while ($exportTask1.State -eq "Running" -or $exportTask2.State -eq "Running") 
                                        {                       
                                        start-sleep 5
                                        write-host -NoNewline  `r"-->" $vm $exportTask1.PercentComplete"% Completed," 
                                        Write-host -NoNewline  ""$vm1 $exportTask2.PercentComplete"% Completed." `r -foregroundcolor Gray
                                        }
                                    Write-Host ""
                                    Write-Host ""
                                    }
    $VMCount = (get-childitem $destFolder).count
                            }
Until ($VMCount -eq $Total)
}

                } #end Choice  
    
        default{write-host "Invalid entry..." -ForegroundColor green ; sleep 3}

    } #end Switch


}

Function Cleanup-VMsforAzure
{
    [string]$title = "CLEANUP AZURE IMPORTS FOLDER IN VCENTER"
    write-host ""
    Write-Host "============ $Title ============" -ForegroundColor Yellow
    write-host ""

    $VMs = (Get-Folder $folder | Get-VM) | sort
    foreach ($vm in $VMs) { write-host $vm.name `t-`t   $vm.powerstate -ForegroundColor Yellow }
    
    if ($VMs.count -ne 0)
    {
        write-host ""
        write-host "Please confirm to DELETE ALL the VMs above from Azure Imports folder in vCenter."
        Write-Host "NOTE: Any powered on VMs will be shutdown and also deleted. This action cannot be reversed!"
        $Confirm = Read-Host "(Y/N)"

        if ($confirm -eq 'y')
        {
            foreach ($vm in $VMs)
            {
                write-host `r -NoNewline "Removing : " -ForegroundColor Yellow
                write-host `r -NoNewline $VM -ForegroundColor Green
                if ($vm.powerstate -eq "PoweredOff"){Stop-VM $vm -ErrorAction SilentlyContinue -Confirm:$false | Out-Null}
                $vm | Remove-VM -DeletePermanently -Confirm:$false
            }
            
            Write-Host "All VMs deleted successfully" -ForegroundColor Green
            sleep 1
        
        }
        else
        {
            Write-Host "Going back..." -ForegroundColor Yellow
            sleep 1
        }
    }
    else
    {
        write-host "No VMs found in Azure Import folder..." -ForegroundColor Magenta
        sleep 2
    }
  
}

Function Convert-VMDKtoVHD
{
    
    $title = "SELECT FOLDER CONTAINING EXPORTED OVF TEMPLATES"
    $list = @((Get-ChildItem $destPath -Directory | where {$_.Name -notlike "*VHD*"}).Name)

    switch (Show-Menu -List $list -title $title)
    {
        $choice
        {
            if ($choice -eq 'Q') { write-host "Quitting..." -ForegroundColor Red ; Show-MainMenu}
                              
            write-host ""
            $exportFolderSelection = $list[$choice - 1]
            Write-Host "Getting VMDK virtual disks in: $exportFolderSelection. Please wait..." -ForegroundColor Yellow
            sleep 1
        
            $fileObjs  = Get-childItem -File ($destPath + "\" + $exportFolderSelection) -recurse | where {$_.name -like "*.vmdk" }
            $fileList = @(($fileObjs).Name | sort)
            $title = "SELECT VMDK TO CONVERT"

            switch (Show-Menu -List $fileList -title $title)
            {
                $choice {
                        if ($choice -eq 'q'){ write-host "Quitting..." -ForegroundColor Red ; Show-MainMenu }

                        $fileSelection  = $fileList[$choice - 1]
                        $vmdkSourcePath = $destPath + "\" + $exportFolderSelection
                        $fileObj        = Get-childItem -File $vmdkSourcePath -recurse | where {$_.name -like $fileSelection }
                        $vmdkSourceFile = $fileObj.FullName
                        $vhdDestPath    = $destPath + "\" + "VHD\"
                        $vhdDestFile    = $vhdDestPath + $fileObj.Name -replace ".vmdk",".vhd"
                        
                        write-host ""
                        write-host "Source VMDK file  =  " -foregroundcolor Green -nonewline
                        write-host $vmdkSourceFile -ForegroundColor Yellow
                        write-host "Target VHD file   =  " -foregroundcolor Green -nonewline
                        write-host $vhdDestFile -ForegroundColor Yellow
                        write-host ""
                        Write-Host "NOTE - The source VMDK file will be deleted following conversion to VHD" -ForegroundColor Magenta
                        write-host ""
                
                        $Confirm = Read-Host "Please confirm to convert the above VMDK to VHD: (Y/N)"

                        if ($confirm -eq 'y')
                        {
                            # Import Microsoft Virtual machine Converter module 
                            if (-not (Get-Module -Name MvmcCmdlet -ErrorAction SilentlyContinue)) {
                            Import-Module $MVMCPath
                            }

                            write-host ""
                            Write-Host "Converting VMDK to VHD. Please wait..." -ForegroundColor Yellow
                            $convert = ConvertTo-MvmcVirtualHardDisk -SourceLiteralPath $vmdkSourceFile -DestinationLiteralPath $vhdDestPath -VhdType DynamicHardDisk -VhdFormat Vhd -ErrorAction SilentlyContinue
                            write-host "--> conversion completed successfully" -ForegroundColor Green


                            Write-Host ""
                            Write-Host "Source VMDK will now be deleted. Please wait..." -ForegroundColor Yellow
                            if (Test-Path $vhdDestFile)
                            {
                                Remove-Item (gci (gci $vmdkSourcePath).FullName | where {$_.Name -like $fileSelection}).FullName -Recurse -Force
                                write-host "--> VMDK deleted successfully" -ForegroundColor Green
                            }
                            
                            sleep 5
        
                        }
                        else
                        {
                            Write-Host "Going back..." -ForegroundColor Yellow
                            sleep 1
                        }
                                                
                        Show-MainMenu

                }
            } #end Switch
        
        }

        default{write-host "Invalid entry..." -ForegroundColor Red}
    }
}

Function UploadTo-Azure
{
   
    # Import Azure PowerShell module for cmdlets
    # Download from: https://azure.microsoft.com/en-us/downloads/?fb=en-us
    if (-not (Get-Module -Name Azure -ErrorAction SilentlyContinue)) 
    {
        Import-Module Azure
    }

    $vhdPath           = "\\ioddd01\BM_Azure\VHD"
    #$vhdPath            = "D:\EXPORTS\VHD\"

    #$filepath          = "c:\image\"   
    $subscriptionName   = "Enterprise Dev/Test"
    $resourceGroup      = "Scalability"
    $containerUri       = "https://scalabilitystd.blob.core.windows.net/"
    $StorageAccountName = "scalabilitystd"

    $title = "SELECT VHD TO UPLOAD TO AZURE PORTAL"
    $list = @((Get-ChildItem $vhdPath).Name)

    switch (Show-Menu -List $list -title $title)
    {
        $Choice { if ($choice -eq 'q'){Show-MainMenu}
            
                $sourceFile    = $list[$choice - 1]
                $sourceVer     = (($sourceFile -split "_")[1]) -replace '[\W]', ''
                $sourcePath    = (Get-ChildItem $vhdPath)[$choice - 1].FullName
                $destContainer = "gm-" + $sourceVer + "-import"
                $destPath      = $containerUri + "$destContainer" + "/" + $sourceFile
            
                #Log in to Azure
                #Write-Host ""
                #write-host "Not logged in. Please log into Azure..." -ForegroundColor Yellow
                $login = Login-AzureRmAccount
                
                Write-Host ""
                write-host "Source VHD location =  " -foregroundcolor Green -nonewline
                write-host $sourcePath -ForegroundColor Yellow 

                #Define the destination storage account and context.
                $StorageAccountKey  = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroup -Name $StorageAccountName).value[0]
                $StorageContext     = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

                write-host "Resource Group      =  " -foregroundcolor Green -nonewline
                write-host $resourceGroup -ForegroundColor Yellow 
                write-host "Storage Account     =  " -foregroundcolor Green -nonewline
                write-host $StorageAccountName -ForegroundColor Yellow
                write-host "Storage Container   =  " -foregroundcolor Green -nonewline
                write-host $destContainer -ForegroundColor Yellow
                write-host "Target VHD location =  " -foregroundcolor Green -nonewline
                write-host $destPath -ForegroundColor Yellow
                write-host ""

                $Confirm = Read-Host "Please confirm upload of the above VHD: (Y/N)"

                if ($confirm -eq 'y')
                {
                    #Check if container already exists
                    $containerCheck = Get-AzureStorageContainer $destContainer -Context $StorageContext -ea SilentlyContinue
                    if ( !($containerCheck))
                    {
                        write-host ""
                        write-host "Target storage container does not exist..." -ForegroundColor Magenta
                        write-host ""
                        $confirm = read-host "--> Please confirm to create the above Storage Container: $destContainer (Y/N)"

                        if ($confirm -eq 'y')
                        {
                            # Create container
                            $newContainer       = New-AzureStorageContainer -Name $destContainer -Permission Off -Context $StorageContext
                            write-host "--> Storage container created successfully" -ForegroundColor Green

                            # Upload VHD to new conatiner
                            write-host ""
                            Write-Host "Uploading VHD file to Azure storage container. Please wait..." -ForegroundColor Yellow
                            $uploadTask = Add-AzureRmVhd -LocalFilePath $sourcePath -ResourceGroupName $resourceGroup -Destination $destPath -NumberOfUploaderThreads 36 -OverWrite | out-null
                            Write-Host "--> VHD uploaded successfully" -ForegroundColor Green
                            write-host "Logging out from Azure" -ForegroundColor Yellow
                            Clear-AzureProfile -force
                            sleep 5
                        }
                        else
                        {
                            write-host "Going back..." -ForegroundColor Yellow
                            sleep 1
                            Show-MainMenu
                        }
                    }
                    else
                    {
                        write-host ""
                        write-host "Storage container:" $destContainer "exists. Continuing with upload...." -ForegroundColor Yellow
                        sleep 1

                        # Upload VHD to new conatiner
                        write-host ""
                        Write-Host "--> Uploading VHD file to Azure storage container. Please wait..." -ForegroundColor Yellow
                        $uploadTask = Add-AzureRmVhd -LocalFilePath $sourcePath -ResourceGroupName $resourceGroup -Destination $destPath -NumberOfUploaderThreads 36 -OverWrite | out-null
                        Write-Host "--> VHD uploaded successfully" -ForegroundColor Green
                        write-host "Logging out from Azure" -ForegroundColor Yellow
                        Clear-AzureProfile -force
                        sleep 5

                        Show-MainMenu
                    }
                }
                else
                {
                    Write-Host "Going back..." -ForegroundColor Yellow
                    sleep 1
                    Show-MainMenu
                }

        } # end Choice
    } #end Switch
}

#endregion FUNCTIONS

#region VARIABLES 

    $ProgressPreference  = ’SilentlyContinue’
#    [String]$FPVC        = "10.1.101.180"
    [String]$IOBVC       = "10.75.4.180"
#    [String]$VCuser      = "administrator"
    [String]$VCuser      = "administrator@vsphere.local"
#    [String]$VCpass      = "8lu3m3`$a"
    [String]$VCpass      = "Password1234`$"
#    $targetVMHost        = "derucsesx01.mgsops.net"
    $targetVMHost        = "iob0157.mgsops.net"
#    $targetDatastore     = "DERTINTRI10"
    $targetDatastore     = "IOBTINTRI02"
#    $Source              = "\\derdd01\data\col1\BlueMesa\Exports\"
    $Source              = "\\ioddd01\Bluemesa\Exports\"
    $destPath            = "\\ioddd01\BM_Azure"
#    $destPath            = "D:\EXPORTS"
#    $folderName          = "Azure_Imports"
    $folderName          = "Azure_Export"
    [String]$guestUser   = "bluemesa"
    $guestPass           = ConvertTo-SecureString "password1234$" -AsPlainText -Force
    $guestCreds          = new-object -typename System.Management.Automation.PSCredential -argumentlist $guestUser,$guestPass
    $MVMCPath            = "C:\Program Files\Microsoft Virtual Machine Converter\MvmcCmdlet.psd1"

#endregion VARIABLES 


#region SCRIPT BODY

Script-Title
Add-ManagementModules
Connect-ManagementServers
1
$Folder = (Get-Folder $folderName).Name

Show-MainMenu

Disconnect-ManagementServers

pause

#endregion SCRIPT BODY