# Developing on Windows

We're going to use `Windows Server 2019 Standard` in this example so let's start by changing the directory and initializing the bolt module.

```bash
cd windows/server-2019
bolt module install --project ../bootstrap
```

Once Bolt has finished downloading dependencies we can boot up our `vagrant` machine.

```bash
vagrant up
```

After the machine starts it will get bootstrapped for development. See [bootstrap.ps1](windows/bootstrap/plans/init.pp) for more information.

Let's start by accessing our new machine (You'll need an RDP client installed!).

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

Open VSCode and start a new terminal.

```PowerShell
code .
```

Debugging requires a few extra gems. For this, we generally create a local Gemfile so that we don't add any unnecessary dependencies to our main Gemfile.

For this, you can use the following helper function that will be available in your current session.

```PowerShell
New-LocalGemfile
```

Now run `bundle install` to pull down dependencies.

```PowerShell
bundle install --path .bundle/gems
```

Once the dependencies have been installed we need to initialize the module for development.

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
