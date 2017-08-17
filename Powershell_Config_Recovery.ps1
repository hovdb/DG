$ComputerNames = Get-Content -Path "C:\ConfRecovery\computers.txt"
 
foreach($Computer in $ComputerNames)
{
 
    try{
  
Copy-Item "C:\ConfRecovery\*" -Destination "\\$computer\C$\dg1" -Recurse

CMD /c  SC \\$computer start winrm
.\PsExec.exe \\$computer -s -h -d powershell.exe "enable-psremoting" -force 
Start-Sleep 5

New-PSSession -ComputerName "$computer"
 
invoke-command -ComputerName $computer -ScriptBlock { & 'C:\dg1\dgkillexe.exe'}
#Copy-Item "C:\ConfRecovery\dg1\{CC6106QA-C7FA-4EA9-B82F-98530B77672D}" -Destination "\\$computer\C$\Program Files\DGAgent\" #Cert Hash
#Copy-Item "C:\ConfRecovery\dg1\{17A6EW20-A13C-8AF1-196E-E32057311C09}.cer" -Destination "\\$computer\C$\Program Files\DGAgent\" #Cert identifier
invoke-command -ComputerName $computer -ScriptBlock { & 'C:\dg1\dgsecure.exe'  '-E' 'c:\dg1\config_plain.xml' 'c:\program files\dgagent\config.xml' '-k:recoverykeypass' '-f'}
.\psexec \\$computer net start dgservice
CMD /c  SC \\$computer stop winrm
Remove-Item \\$computer\c$\dg1 -force -Recurse
}

catch{
        Write-Error "Failed to connect to $Computer"
    }
    }
