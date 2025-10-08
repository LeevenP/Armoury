#Author Lee
#
# globals
$VMuser = "localhost\bluemesa"
$VMpass = ConvertTo-SecureString "password1234$" -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $VMuser,$VMpass

$Server = "webserver4"

function funcGetPID {

 Write-Host "Grafting on $Server" -ForegroundColor Green
 Invoke-Command -ComputerName $Server -credential $cred -ScriptBlock {   Invoke-Expression -Command:"cmd.exe /c 'C:\Windows\system32\inetsrv\appcmd.exe list wp'" }
}

$work = funcGetPID
$trip = $work.Count
$num = 1

foreach ($PD in $work){

  Write-Host "[$num of $trip]" -ForegroundColor Magenta
  
  $PageMem = (Invoke-Command -ComputerName $Server -credential $cred -ScriptBlock {param ($PD) Get-Process -PID $PD.Split('"')[1] | Select-Object -Property PrivateMemorySize64 } -ArgumentList $pd).PrivateMemorySize64 / 1024 / 1024
  Write-host "App Pool" $PD.Split(':'')')[1] "Has " -f Gray -NoNewline; write-host $PageMem -f yello -NoNewline; write-host " Megabytes Allocated" -f Gray

  $num++
}