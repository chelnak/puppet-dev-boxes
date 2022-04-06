# The following code was heavily inspired by the following source:
# https://github.com/puppetlabs/Puppet.Dsc/blob/main/extras/install.ps1

$Packages = @(
    'vscode',
    'googlechrome',
    'git',
    'curl',
    'poshgit'
)

$Modules = @(
    @{ Name = 'RubyInstaller' }
)

Write-Host 'Installing Chocolatey'
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install $Packages --yes --no-progress --stop-on-first-failure --ignore-checksums
if ($LastExitCode -ne 0) {
    throw 'Installation with choco failed.'
}

Write-Host 'Reloading Path to pick up installed software'
Import-Module C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1
Update-SessionEnvironment

ForEach ($Module in $Modules) {
    $InstalledModuleVersions = Get-Module -ListAvailable $Module.Name -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Version
    If ($Module.ContainsKey('RequiredVersion')) {
        $AlreadyInstalled = $null -ne ($InstalledModuleVersions | Where-Object -FilterScript { $_ -eq $Module.RequiredVersion })
    }
    Else {
        $AlreadyInstalled = $null -ne $InstalledModuleVersions
    }
    If ($AlreadyInstalled) {
        Write-Verbose "Skipping $($Module.Name) as it is already installed at $($InstalledModuleVersions)"
    }
    Else {
        Write-Verbose "Installing $($Module.Name)"
        Install-Module @Module -Force -SkipPublisherCheck -AllowClobber
    }
}

Import-Module 'RubyInstaller'
Install-Ruby -RubyVersions @('2.7.2-1 (x64)') -Verbose

# Enable RDP
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Make code directory
mkdir -p $env:userprofile\code

Write-Host "Box bootstrapped! You can now run 'vagrant rdp'"