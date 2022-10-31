# Developing on Windows

## Provision the Vagrant box

We're going to use `Windows Server 2019` in this example so let's start by booting up our `vagrant` machine.

```bash
make windows server-2019 up
```

After the machine starts it will get bootstrapped for development.
See the bootstrap [module](windows/bootstrap/plans/init.pp) for more information.

Let's start by accessing our new machine.

```bash
make windows server-2019 rdp
```

Log in with the following details:

* **user**: vagrant
* **password**: vagrant

## Clone your module

Once you have a remote ssh session established with your remote machine, open a new terminal and clone your module.

```PowerShell
git clone https://github.com/puppetlabs/puppetlabs-chocolatey
cd puppetlabs-chocolatey
```

## Making sure Git is authenticated

During bootstrap, `gh-cli` is installed.
We can use it to authenticate git and persist our access tokens.

From a terminal run `gh auth login` and follow the instructions ensuring that you choose `https` when asked to choose a protocol.

## Install dependencies

From inside the module directory run `bundle install`.
Gems will be saved locally to `./.bundle/gems`.

```bash
bundle install
```

Once the dependencies have been installed we need to initialize the module for development.

```bash
bundle exec rake spec_prep
```

Underneath the `spec/fixtures/` you should now have the following directories:

* modules: `spec/fixtures/modules`
* manifests: `spec/fixtures/manifests`

You can define test classes in `spec/fixtures/manifests/site.pp`.
Alternatively, you can run any of the examples provided with the module.

# Running Puppet

The only thing left to do now is to make some changes and apply the manifest. You can do this by executing the following command:

```PowerShell
bundle exec puppet apply .\spec\fixtures\manifests\site.pp --modulepath .\spec\fixtures\modules\ --debug
```
