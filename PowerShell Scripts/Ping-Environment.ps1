<#
.Synopsis
    Script to ping a vCloud environment by its external IPs

.DESCRIPTION
        
    Requirements: 
    - PowerShell 4.0 or higher
    - PowerCLI 6 R2 or higher
    - Microsoft Virtual Machine Converter 3.0 or higher (https://www.microsoft.com/en-za/download/details.aspx?id=42497)

.EXAMPLE
    C:\SCRIPTS\.\Ping.ps1

Team:		IT Environments Team - Environment Management (ITEnvironments-EM@derivco.com)
Date:		MAY 2017
Version:    2.0

#>


#region FUNCTIONS

Function Script-Title
{
    # SETS SCRIPT TITLE DURING RUNTIME
    cls
    $windowTitle = "IT ENVIRONMENTS - Ping Environment"
    $host.ui.RawUI.WindowTitle = $windowTitle
    Write-Host ""
    Write-Host "========================================================================" -ForegroundColor Yellow `r
    Write-Host "  $windowTitle" -ForegroundColor Yellow `r
    Write-Host "========================================================================" -ForegroundColor Yellow `r
    Write-Host ""
}

Function ConnectTo-Site ($site)
{
    write-host ""
    if ($site -eq "FP")
    {
        Write-host "Connecting to FP vCloud. Please wait..." -ForegroundColor Yellow
        Connect-CIServer -Server $FPVCD -user $VCDuser -password $VCDpass -wa 0 | out-null
    }
    else    
    {
        if ($site -eq "IOM")
        {
            Write-host "Connecting to IOM vCloud. Please wait..." -ForegroundColor Yellow
            Connect-CIServer -Server $IOMVCD -user $VCDuser -password $VCDpass -wa 0 | out-null
        }
        if ($site -eq "HKO")
        {
            Write-host "Connecting to HKO vCloud. Please wait..." -ForegroundColor Yellow
            Connect-CIServer -Server $HKOVCD -user $VCDuser -password $VCDpass -wa 0 | out-null
        }
    }

    Write-host "--> Connected" -ForegroundColor Green
    Write-host ""

}

Function Ping-Env ($site)
{
    ConnectTo-Site -site $site

    Write-Host "Collecting Organisations. Please wait..." -foregroundcolor Yellow
    $Org = Get-Org | sort | Out-GridView -PassThru -Title "Please select ORG, and click OK:"
    Write-Host "-->" $Org "selected..." -foregroundcolor Green
    write-host ""

    Write-Host "Collecting Environments. Please wait..." -foregroundcolor Yellow
    $envName = Get-Org $org | Get-CIVapp | sort | Out-GridView -PassThru -Title "Please select ENVIRONMENT, and click OK"
    Write-Host "-->" $envName "selected..." -foregroundcolor Green
    write-host ""
    
    Write-Host "Collecting IP addresses. Please wait..." -foregroundcolor Yellow
    write-host ""

    $env = "'%$envName%'"

    $envDetails = invoke-sqlcmd -query "select tbvmt.name, tbe.Name, tbvm.ExternalIpAddress from tb_VirtualMachine tbvm
    inner join tb_VirtualMachineType tbvmt
    on tbvm.VirtualMachineTypeId = tbvmt.VirtualMachineTypeId
    inner join tb_environment tbe
    on tbe.EnvironmentID = tbvm.EnvironmentID
    where tbvm.EnvironmentId in (select environmentid from tb_Environment where name like $env and name not like '%BOT%')
    and tbvm.VirtualMachineTypeId <> 0 and tbvm.VirtualMachineTypeId <> 40
    and tbvm.ExternalIpAddress not like 'NO IP ADDRESS FOUND' and tbvm.ExternalIpAddress not like 'NO IPADDRESS' and tbvm.ExternalIpAddress not like '10.125.248.%'
    order by tbe.name, tbvmt.name" -ServerInstance "derbmops2" -Database "BlueSuite"

    $envDetails | select ExternalIpAddress,name | ft -HideTableHeaders | out-file $outputFile -force
    Write-Host "--> done" -foregroundcolor Green
    write-host ""

    Write-host "Opening PingInfoView. Please wait..." -ForegroundColor Yellow
    Start-Process $PIVexe "/loadfile $outputFile /IPHostDescFormat 1"
    Write-Host "--> done" -foregroundcolor Green
    write-host ""
    
    DisconnectFrom-Site -site $site
    
    sleep 3

}

function Show-MainMenu
{
    do
    {
        [string]$title = "MAIN MENU"
        $list = @("Ping an FP Environment","Ping an IOM Environment","Ping a HKO Environment")

        switch ( Show-Menu -List $List -title $title )
        {
            1 { Ping-Env -site "FP" }
            2 { Ping-Env -site "IOM" }
            3 { Ping-Env -site "HKO" }
        }
    }
    while ($choice -ne 'q')
    write-host ""
    Write-Host "Quitting..." -ForegroundColor Red
    sleep 1
    Break
}

function Show-Menu
{
    param($List,$title)
    cls
    Script-Title
    write-host ""
    Write-Host "============= $Title =============" -ForegroundColor Yellow
    write-host ""

    $i = 1

    Foreach ($global:item in @($List))
        {
        Write-Host $i ")" `t -ForegroundColor Green -NoNewline
        Write-Host $item -ForegroundColor Yellow
        $i++
        }
    
    write-host ""
    write-host "Q )" `t -foregroundcolor Green -NoNewLine
    write-host "QUIT" -ForegroundColor Yellow
    write-host ""

    $global:Choice = Read-Host "Please make your selection: (1 - $($i - 1))"
    Return $Choice

} 

Function DisconnectFrom-Site ($site)
{
    write-host ""
    if ($site -eq "FP")
    {
        Disconnect-CIServer -Server $FPVCD -Confirm:$false -wa 0 | out-null
    }
    else    
    {
        if ($site -eq "IOM")
        {
            Disconnect-CIServer -Server $IOMVCD -Confirm:$false -wa 0 | out-null
        }
        else
        {
            if ($site -eq "HKO")
            {
                Disconnect-CIServer -Server $HKOVCD -Confirm:$false -wa 0 | out-null
            }
        }
    }

}

#endregion FUNCTIONS


#region VARIABLES

$FPVCD      = "10.1.101.xx"
$IOMVCD     = "10.75.4.xx"
$HKOVCD     = "10.7.101.xx"
$VCDuser    = "administrator"
$VCDpass    = "8lu3m3`$a"
$outputFile = "C:\temp\PingInfoView_hosts.txt"
$PIVexe     = "C:\BluemesaRepo\Re-Provision_Weekend\Tools\WeekendRepro\PingInfoView.exe"

#endregion VARIABLES


#region SCRIPT BODY

Show-MainMenu

Read-Host "Press any key to exit..."

#endregion SCRIPT BODY