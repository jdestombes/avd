#Julien Destombes
#Optimize Default User Settings

Begin {

    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        Write-Host "Customization : Windows Optimizations"

        $WindowsVersion = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\").ReleaseId
        $WorkingLocation = (Join-Path $PSScriptRoot $WindowsVersion)
        $templateFilePathFolder = "C:\AVDImage"

        if (!(Test-Path -Path $WorkingLocation)) {
            New-Item -Path $WorkingLocation -ItemType Directory
        }

        Write-Host "Customization : Windows Optimizations - Windows version is $WindowsVersion"
    } 
    catch
    {
        Write-Host 'Customization : Windows Optimizations - Invalid Path $WorkingLocation - Exiting Script!'
        Return
    }
}
PROCESS {

    $DefaultUserSettingsFilePath = Join-Path -Path $WorkingLocation -ChildPath 'DefaultUserSettings.json'
    if($WindowsVersion -eq "2004") {
        $DefaultUserSettingsUrl = "https://raw.githubusercontent.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/main/2004/ConfigurationFiles/DefaultUserSettings.json"
    } 
    else {
        $DefaultUserSettingsUrl = "https://raw.githubusercontent.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/main/2009/ConfigurationFiles/DefaultUserSettings.json"
    }

    Invoke-WebRequest $DefaultUserSettingsUrl -OutFile $DefaultUserSettingsFilePath -UseBasicParsing

    If (Test-Path $DefaultUserSettingsFilePath)
    {
        Write-Host "Customization : Windows Optimizations - - Set Default User Settings"
        $UserSettings = (Get-Content $DefaultUserSettingsFilePath | ConvertFrom-Json).Where( { $_.SetProperty -eq $true })
        If ($UserSettings.Count -gt 0)
        {
            Write-Host "Customization : Windows Optimizations - Processing Default User Settings (Registry Keys)" 
            $null = Start-Process reg -ArgumentList "LOAD HKLM\VDOT_TEMP C:\Users\Default\NTUSER.DAT" -PassThru -Wait
            # & REG LOAD HKLM\VDOT_TEMP C:\Users\Default\NTUSER.DAT | Out-Null

            Foreach ($Item in $UserSettings)
            {
                If ($Item.PropertyType -eq "BINARY")
                {
                    $Value = [byte[]]($Item.PropertyValue.Split(","))
                }
                Else
                {
                    $Value = $Item.PropertyValue
                }

                If (Test-Path -Path ("{0}" -f $Item.HivePath))
                {
                    Write-Host "Customization : Windows Optimizations - Found $($Item.HivePath) - $($Item.KeyName)"

                    If (Get-ItemProperty -Path ("{0}" -f $Item.HivePath) -ErrorAction SilentlyContinue)
                    {
                        Write-Host "Customization : Windows Optimizations - Set $($Item.HivePath) - $Value"
                        Set-ItemProperty -Path ("{0}" -f $Item.HivePath) -Name $Item.KeyName -Value $Value -Type $Item.PropertyType -Force 
                    }
                    Else
                    {
                        Write-Host "Customization : Windows Optimizations- New $($Item.HivePath) Name $($Item.KeyName) PropertyType $($Item.PropertyType) Value $Value"
                        New-ItemProperty -Path ("{0}" -f $Item.HivePath) -Name $Item.KeyName -PropertyType $Item.PropertyType -Value $Value -Force | Out-Null
                    }
                }
                Else
                {
                    Write-Host "Customization : Windows Optimizations- Registry Path not found $($Item.HivePath)" 
                    Write-Host "Customization : Windows Optimizations- Creating new Registry Key $($Item.HivePath)"
                    $newKey = New-Item -Path ("{0}" -f $Item.HivePath) -Force
                    If (Test-Path -Path $newKey.PSPath)
                    {
                        New-ItemProperty -Path ("{0}" -f $Item.HivePath) -Name $Item.KeyName -PropertyType $Item.PropertyType -Value $Value -Force | Out-Null
                    }
                    Else
                    {
                        Write-Host "Customization : Windows Optimizations- Failed to create new Registry Key" 
                    } 
                }
            }
            $null = Start-Process reg -ArgumentList "UNLOAD HKLM\VDOT_TEMP" -PassThru -Wait
            # & REG UNLOAD HKLM\VDOT_TEMP | Out-Null
        }
        Else
        {
            Write-Host "Customization : Windows Optimizations- No Default User Settings to set" 
        }
    }
    Else
    {
        Write-Host "Customization : Windows Optimizations- File not found: $DefaultUserSettingsFilePath"
    }   
}
END {
    #Cleanup
    if ((Test-Path -Path $templateFilePathFolder -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $templateFilePathFolder -Force -Recurse -ErrorAction Continue
    }

    if ((Test-Path -Path $WorkingLocation -ErrorAction SilentlyContinue)) {
        Remove-Item -Path $WorkingLocation -Force -Recurse -ErrorAction Continue
    }

    $stopwatch.Stop()
    $elapsedTime = $stopwatch.Elapsed
    Write-Host "*** CUSTOMIZER PHASE : Windows Optimizations - Exit Code: $LASTEXITCODE ***"    
    Write-Host "Customization : Windows Optimizations - Ending Customization : Windows Optimizations - Time taken: $elapsedTime"
}