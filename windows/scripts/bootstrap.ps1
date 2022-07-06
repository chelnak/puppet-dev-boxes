$ProgressPreference = "SilentlyContinue"
$ToolsDirectory = "C:\tools"
$null = mkdir $ToolsDirectory
$null = mkdir $ENV:UserProfile\code

function Install-Application {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Installer,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$ExePath,
        [Parameter(Mandatory = $true, Position = 2)]
        [string]$Arguments
    )

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $Installer -OutFile $ExePath

    $Proc = Start-Process -FilePath $ExePath -ArgumentList $Arguments -PassThru -Wait
    if ($Proc.ExitCode -ne 0) {
        Write-Error "Installation failed for $($Installer.split("/")[-1])}!" -ErrorAction Stop
    }
}

function Install-Chrome {
    $Installer = "http://dl.google.com/chrome/install/375.126/chrome_installer.exe"
    $ExePath = "$ToolsDirectory\chrome.exe"
    $InstallArgs = "/silent /install"

    Install-Application -Installer $Installer -ExePath $ExePath -Arguments $InstallArgs
}

function Install-VSCode {
    Write-Host "-> Installing VSCode"
    $Installer = "https://az764295.vo.msecnd.net/stable/e18005f0f1b33c29e81d732535d8c0e47cafb0b5/VSCodeSetup-x64-1.66.0.exe"
    $ExePath = "$ToolsDirectory\vscode.exe"
    $InstallArgs = "/VERYSILENT /NORESTART /MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,desktopicon"

    Install-Application -Installer $Installer -ExePath $ExePath -Arguments $InstallArgs
}

function Install-Git {
    Write-Host "-> Installing Git"
    $Installer = "https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-64-bit.exe"
    $ExePath = "$ToolsDirectory\git.exe"
    $InstallArgs = "/VERYSILENT /NORESTART"

    Install-Application -Installer $Installer -ExePath $ExePath -Arguments $InstallArgs
}

function Install-PoshGit {
    Write-Host "-> Installing PoshGit"
    Install-Module PowershellGet -Force
    Install-Module posh-git -Scope CurrentUser -Force
}

function Install-Ruby {
    $Rubies = @{
        "2.5.8" = "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.5.8-1/rubyinstaller-devkit-2.5.8-1-x64.exe"
        "2.7.5" = "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.5-1/rubyinstaller-devkit-2.7.5-1-x64.exe"
    }

    Write-Host "-> Installing Ruby"

    if ($Env:RUBY_VERSION) {
        $Installer = $Rubies[$Env:RUBY_VERSION]
    } else {
        Write-Host "-> Ruby version not detected, defaulting to 2.7.5"
        $Installer = $Rubies["2.7.5"]
    }

    $ExePath = "${ToolsDirectory}\ruby.exe"
    $InstallArgs = "/silent /tasks='assocfiles,modpath'"

    Install-Application -Installer $Installer -ExePath $ExePath -Arguments $InstallArgs
}

Install-Git
Install-Ruby
Install-VSCode
Install-PoshGit
Install-Chrome

Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Write-Host "Box bootstrapped! You can now run 'vagrant rdp'"
