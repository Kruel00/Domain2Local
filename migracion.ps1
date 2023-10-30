

Set-Location $env:HOMEDRIVE\users
$listaUsuarios = Get-ChildItem 

Add-Type -AssemblyName System.Windows.Forms
$Form = New-Object system.Windows.Forms.Form
$Form.Font = $Font
$Form.Text = 'Migracion de usuarios'
$Form.Width = 350
$Form.Height = 150

#Controls
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Select <company\<Username> as profile to migrate"
$label.Location = New-Object Drawing.Point 30,10
$Label.AutoSize = $True
$Form.Controls.Add($Label)

$boton1 = New-Object System.Windows.Forms.Button
$boton1.Text = "OK"
$boton1.Location = New-Object Drawing.Point 50,60
$boton1.Width = 100
$form.Controls.add($boton1)


$boton2 = New-Object System.Windows.Forms.Button
$boton2.Text = "Cancel"
$boton2.Location = New-Object Drawing.Point 180,60
$boton2.Width = 100
$form.Controls.add($boton2)

$ComboBox1 = New-Object System.Windows.Forms.ComboBox
$ComboBox1.Items.AddRange($listaUsuarios)
$ComboBox1.Location = New-Object Drawing.Point 15,30
$combobox1.Width = 300
$Combobox1.SelectedIndex = 1
$form.Controls.add($Combobox1)

$boton2.Add_Click({
$form.Close()
})

$boton1.add_Click({
$user = $ComboBox1.SelectedItem.ToString()
#copiar archivo de backup
$valuDir = $env:HOMEDRIVE + "\company"


if (!test-path $valuDir){
    mkdir $valuDir
}

Copy-Item -Path "\\b1fs\Shared\ITSupport\IT_Stuff\MigrateAcount\Data\StartRecovery.rec" $valuDir + "\StartRecovery.ps1" -recurse -passthru

#Creacion de usuario
    $Password = ConvertTo-SecureString -String "abc123!@#" -AsPlainText -force
    New-LocalUser -Name $user -Password $Password -Description "Creado con scrip para migracion" 
    Add-LocalGroupMember -Group "Administrators" -Member $user


#crear batch batch de copia de archivos
$pathStartFile = $env:programdata + "\Microsoft\Windows\Start Menu\Programs\StartUp\recovery-data.bat"

if(test-path $pathStartFile){
     Remove-Item $pathStartFile
}
new-item $pathStartFile

#Contenido del batch recovery-data.bat
'@echo off 
    start powershell "c:\company\StartRecovery.ps1"
' | set-content $pathStartFile 

#Renombrar folder de usuario
$pathUser = $env:HOMEDRIVE + "\users\" + $user	    
$DirUserOld = $pathUser + ".Backup"
Rename-Item $pathUser $DirUserOld

#Autologin nuevo usuario
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value $user
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value "1"
Set-ItemProperty -path "hklm:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value "abc123!@#"
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name legalnoticecaption -Value ""
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name legalnoticetext -Value ""

Add-Computer -WorkgroupName companydomain -Force
write-host "Proceso finalizado"
pause
shutdown -r -t 0
})
$Form.ShowDialog()


