# Developing on Windows

We're going to use `Windows Server 2019 Standard` in this example so lets start by changing directory and booting up our `vagrant` machine.

```bash
cd windows/server-2019
vagrant up
```

After the machine starts it will get bootstrapped for development. See [bootstrap.ps1](scripts/bootstrap.ps1) for more information.

Lets start by accessing our new machine (You'll need an RDP client installed!).

```bash
vagrant rdp
```

Log in with the following details:

* **user**: vagrant
* **password**: vagrant

Open PowerShell and clone your module:

```PowerShell
git clone https://github.com/puppetlabs/puppetlabs-chocolatey

cd puppetlabs-chocolatey
```

Open vscode and start a new terminal.

```PowerShell
code .
```

Next, we need to activate the correct version of Ruby. The bootstrap process installs ruby with the `RubyInstaller` PowerShell module. We can use this to configure our session.

From the terminal run the following:

```PowerShell
> Get-Ruby

Tag            Description
---            -----------
=> 2.7.2-1-x64 ruby 2.7.2p137 (2020-10-01 revision 5445e04352) [x64-mingw32]


> Select-Ruby -RubyTag 2.7.2-1-x64
```

Debugging requires a few extra gems. For this we generally create a local Gemfile so that we don't have add any unnecessary dependencies in to our main Gemfile.

For this you can use the following helper function that will be available in your current session.

```PowerShell
New-LocalGemfile
```

Now run `bundle install` to pull down dependencies.

```PowerShell
bundle install --path .bundle/gems
```

Once the dependencies have installed we need to initialize the module for development.

```PowerShell
bundle exec rake spec_prep
```

Underneath the `spec/fixtures/` you should now have the following directories:

* modules: `spec/fixtures/modules`
* manifests: `spec/fixtures/manifests`

You can define test classes in `spec/fixtures/manifests/site.pp`

The only thing left to do now is to make some changes and apply the manifest. You can do this by executing the following command:

```PowerShell
bundle exec puppet apply .\spec\fixtures\manifests\site.pp --modulepath .\spec\fixtures\modules\ --debug
```
