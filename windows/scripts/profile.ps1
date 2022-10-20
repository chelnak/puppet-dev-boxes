# The following code was sourced from https://github.com/puppetlabs/Puppet.Dsc/blob/main/extras/profile.ps1!

Function New-LocalGemfile {
    Param (
        [string]$Path
    )
    $Gems = @'
  gem 'fuubar'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
'@
    if ([string]::IsNullOrEmpty($Path)) {
        $Path = Join-Path -Path (Get-Location) -ChildPath 'gemfile.local'
    }
    [IO.File]::WriteAllLines($Path, $Gems)
}

Set-Item -Path Env:\PDK_PUPPET_VERSION -Value '7.16.0'
Set-Item -Path Env:\PATH -Value "$ENV:PATH;C:\Program Files\Git\cmd"
Import-Module posh-git
Set-Location -Path $env:userprofile\code
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\tokyonight_storm.omp.json" | Invoke-Expression
