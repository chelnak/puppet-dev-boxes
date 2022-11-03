# @summary A plan that will configure a Windows development environment.
# @param targets The targets to run on.
plan bootstrap (
  TargetSpec $targets = 'localhost'
) {
  $targets.apply_prep

  $apply_result = apply($targets, _catch_errors => true) {
    $tools_dir = 'C:\tools'

    file { $tools_dir:
      ensure => directory,
    }

    file { "c:\\users\\vagrant\\code":
      ensure => directory,
    }

    # lint:ignore:140chars
    # Note:
    #   There is a bug that prevents this plan from being re run on the same target once ruby is installed.
    # This is because custom_facts.rb will try to load puppet from the newly installed system ruby when
    # it should be targeting the puppet ruby.
    # The error will look like this:
    #
    # ==> server: Failed on server:
    # ==> server:   The task failed with exit code 1 and no stdout, but stderr contained:
    # ==> server:   ruby.exe : C:/Ruby27-x64/lib/ruby/2.7.0/rubygems/core_ext/kernel_require.rb:83:in `require': cannot load such file -- puppet (LoadError) #lint:ignore:140chars
    # ==> server:       + CategoryInfo          : NotSpecified: (C:/Ruby27-x64/l...pet (LoadError):String) [], RemoteException
    # ==> server:       + FullyQualifiedErrorId : NativeCommandError
    # ==> server:   	from C:/Ruby27-x64/lib/ruby/2.7.0/rubygems/core_ext/kernel_require.rb:83:in `require'	from C:/Users/vagrant/AppData/Local/Temp/hjl45aj5.kjs/custom_facts.rb:5:in `<main>' #lint:ignore:140chars
    #
    # The above issue can potentially be solved by specifying the interpreter for the given transport. In this case,
    # the vagrant-bolt plugin does not support this option so it is not
    # possible to work around this issue  until the plugin is updated.
    # lint:endignore

    $apps = [
      {
        name => 'Google Chrome',
        url => 'https://dl.google.com/chrome/install/375.126/chrome_installer.exe',
        destination_filename => 'chrome.exe',
        install_options => ['/silent', '/install'],
      },
      {
        name => 'VS Code',
        url => 'https://az764295.vo.msecnd.net/stable/e18005f0f1b33c29e81d732535d8c0e47cafb0b5/VSCodeSetup-x64-1.66.0.exe',
        destination_filename => 'vscode.exe',
        install_options => ['/VERYSILENT', '/NORESTART', '/MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,desktopicon'],
      },
      {
        name => 'Cygwin',
        url => 'https://cygwin.com/setup-x86_64.exe',
        destination_filename => 'cygwin.exe',
        install_options => ['--quiet-mode', '--no-shortcuts', '--no-startmenu', '--no-desktop', '--local-package-dir=c:\cygwin64', '--site', 'http://mirrors.kernel.org/sourceware/cygwin/', '--packages', 'rsync,unzip,wget,zip,make,x86_64-w64-mingw32-gcc']
      },
      {
        name => 'Git',
        url => 'https://github.com/git-for-windows/git/releases/download/v2.37.3.windows.1/Git-2.37.3-64-bit.exe',
        destination_filename => 'git.exe',
        install_options => ['/VERYSILENT', '/NORESTART'],
      },
      {
        name => 'Ruby',
        url => 'https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.7.6-1/rubyinstaller-devkit-2.7.6-1-x64.exe',
        destination_filename => 'ruby.exe',
        install_options => ['/silent', '/tasks=assocfiles,modpath']
      },
      {
        name => 'gh-cli',
        url => 'https://github.com/cli/cli/releases/download/v2.18.1/gh_2.18.1_windows_amd64.msi',
        destination_filename => 'gh-cli.msi',
        install_options => ['/quiet', '/norestart'],
      }
    ]

    $apps.each |$app| {
      download_file { "Download ${app['name']}":
        url                   => $app['url'],
        destination_directory => $tools_dir,
        destination_file      => $app['destination_filename'],
      }

      package { "Install ${app['name']}":
        ensure          => installed,
        source          => "${tools_dir}\\${app['destination_filename']}",
        install_options => $app['install_options'],
        require         => Download_file["Download ${$app['name']}"],
      }
    }

    $system_gems = [
      {
        name => 'solargraph',
      },
      {
        name => 'bundler',
      },
      {
        name => 'rubocop',
      },
      {
        name => 'rubocop-performance',
      },
      {
        name => 'rubocop-rspec',
      },
      {
        name => 'fuubar',
      },
      {
        name => 'pry-byebug',
      },
      {
        name => 'pry-stack_explorer',
      },
    ]

    $system_gems.each |$gem| {
      exec { "Install ${gem['name']}":
        command => "gem install ${gem['name']} --user-install",
        provider => powershell,
        require => Package['Install Ruby'],
      }
    }

    exec { 'Configure Bundle Path':
      command => "bundle config set --global path './.bundle'",
      provider => powershell,
      require => Package['Install Ruby'],
    }

    $powershell_modules = [
      'PSReadline',
      'posh-git',
    ]

    $powershell_modules.each |$module| {
      exec { "Install PowerShell module ${module}":
        command  => "Install-Module -Name ${module} -Force",
        provider => powershell,
      }
    }

    exec { 'oh-my-ppsh':
      command  => 'Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://ohmyposh.dev/install.ps1"))',
      provider => powershell,
    }

    exec { 'Set Git Path':
      command  => '[Environment]::SetEnvironmentVariable("Path", $ENV:Path + ";C:\Program Files\Git\cmd", [EnvironmentVariableTarget]::Machine)',
      provider => powershell,
      require  => Package['Install Git'],
    }

    exec { 'Set Cygwin Path':
      command  => '[Environment]::SetEnvironmentVariable("Path", $ENV:Path + ";C:\cygwin64\bin", [EnvironmentVariableTarget]::Machine)',
      provider => powershell,
      require  => [
        Package['Install Cygwin'],
        Exec['Set Git Path'],
      ],
    }

    exec { 'Enable Remote Desktop firewall rule':
      command  => 'Enable-NetFirewallRule -DisplayGroup "Remote Desktop"',
      provider => powershell,
    }

    registry_value { 'Enable long file paths':
      ensure => present,
      path   => 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled',
      type   => 'dword',
      data   => 1,
    }

    registry_value { 'Set default SSH shell':
      ensure => present,
      path   => 'HKLM:\SOFTWARE\OpenSSH\DefaultShell',
      type   => 'string',
      data   => 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',
    }

    registry_value { 'Enable Remote Desktop':
      ensure => present,
      path   => 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\fDenyTSConnections',
      type   => 'dword',
      data   => 0,
    }
 }

  run_plan('reboot', $targets)

  out::message('Box bootstrapped!')
  out::message("You can now run 'make [os] [version] rdp' or 'vagrant [os] [version] ssh' to connect to the box.")
}
