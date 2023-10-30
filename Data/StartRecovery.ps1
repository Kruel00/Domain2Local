param([switch]$Elevated) 

function Test-Admin { 
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent()) 
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)          } 
    if ((Test-Admin) -eq $false) {
         if ($elevated) 
            { 
                                 } 
         else { 
            Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
              } 
    exit } 

        #Quitar autologuin
        Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value ""
        Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value "0"
        Set-ItemProperty -path "hklm:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value ""
        Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name legalnoticecaption -Value ""
        Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name legalnoticetext -Value ""
        
        #Copiar respaldo
        $backUpDir = $env:HOMEDRIVE  + '\users\' + $env:USERNAME + '.BackUp'
        $userDir = $env:HOMEDRIVE  + '\users\' + $env:USERNAME
        robocopy $backUpDir $userDir /e /w:1 /r:0
        
        #reset password
        $User = $env:USERNAME
        $Usrstring = "WinNT://localhost/"+$User  
        $usr=[ADSI] $Usrstring  
        $usr.passwordExpired = 1  
        $usr.setinfo()

        #borrar startup
        $rtSttartUp = $env:programdata+"\Microsoft\Windows\Start Menu\Programs\StartUp\recovery-data.bat"
        $buscarF = test-path  $rtSttartUp
        if ($buscarF){remove-item $rtSttartUp}

        #Respaldo correo
        #no se puede
        
        Write-Host "Finalizado"
        pause
	shutdown -r -t 0