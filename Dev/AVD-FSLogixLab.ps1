#Author: Julien Destombes
#Config FSLogix

$registryPath = "HKLM:\SOFTWARE\FSLogix\Profiles"
$ConnectionString = 'BlobEndpoint='

if(!(Test-path $registryPath)){
    try {
        Write-Host "Creating $($registryPath)"    
        New-Item -Path $registryPath -Force | Out-Null
    }
    catch {
        Write-Host "Error: Creating $($registryPath)"
        break
    }
}

try {
    Write-Host "Configure FSLogix connection key"
    & "C:\Program Files\FSLogix\Apps\frx.exe" add-secure-key -key storagefilesservice -value $ConnectionString
}
catch {
    Write-Host "Error: Configure FSLogix connection key"
    break
}

try {
    New-ItemProperty -Path $registryPath -Name "CCDLocations" -Value 'type=azure,name="Azure Blob",connectionString="|fslogix/storagefilesservice|"' -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "Enabled" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "DeleteLocalProfileWhenVHDShouldApply" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "FlipFlopProfileDirectoryName" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Host "Configuring FSLogix"
}
catch {
    Write-Host "Error: Configure FSLogix"
    break
}

#Display script completion in console
Write-Host "Script Executed successfully"