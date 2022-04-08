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

Import-Module posh-git
Set-Location -Path $env:userprofile\code