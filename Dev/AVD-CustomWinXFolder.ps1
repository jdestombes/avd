#Julien Destombes
#Script to customize WINX Default Folder

$shortcuts = Get-ChildItem -Path C:\Users\Default\AppData\Local\Microsoft\Windows\WinX -Recurse -Include '4 - Control Panel.lnk',`
                                                                                                        '5 - Task Manager.lnk',`
                                                                                                        '1 - Run.lnk',`
                                                                                                        '01a - Windows PowerShell.lnk',`
                                                                                                        '02a - Windows PowerShell.lnk',`
                                                                                                        '03 - Computer Management.lnk',`
                                                                                                        '04 - Disk Management.lnk',`
                                                                                                        '04-1 - NetworkStatus.lnk',`
                                                                                                        '05 - Device Manager.lnk',`
                                                                                                        '06 - SystemAbout.lnk',`
                                                                                                        '07 - Event Viewer.lnk',`
    	                                                                                                '08 - PowerAndSleep.lnk',`
                                                                                                        '09 - Mobility Center.lnk',`
                                                                                                        '10 - AppsAndFeatures.lnk'

foreach ($s in $shortcuts) {
    takeown /a /f $s.fullname
    $NewAcl = Get-Acl -Path $s.fullname
    $identity = 'BUILTIN\Administrators'
    $fileSystemRights = 'FullControl'
    $type = 'Allow'
    $fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
    $fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
    $NewAcl.SetAccessRule($fileSystemAccessRule)
    Set-Acl -Path $s.fullname -AclObject $NewAcl
    Remove-Item -Path $s.FullName -Force -Confirm:$false
}

