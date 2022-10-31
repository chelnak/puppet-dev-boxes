# Developing on Ubuntu

## Provisioning the Vagrant box

We're going to use `Ubuntu 20.04` in this example so let's start by booting up our `vagrant` machine.

```bash
make ubuntu 2004 up
```
After the machine starts it will get bootstrapped for development.
See the [Vagrantfile](ubuntu/2004/Vagrantfile) for more information.

Let's start by accessing our new machine.

```bash
make ubuntu 2004 ssh
```

## Clone your module

Once you have a remote ssh session established with your remote machine, open a new terminal and clone your module.

```bash
git clone https://github.com/puppetlabs/puppetlabs-motd
cd puppetlabs-motd
```

## Making sure Git is authenticated

During bootstrap, `gh-cli` is installed.
We can use it to authenticate git and persist our access tokens.

From a terminal run `gh auth login` and follow the instructions ensuring that you choose `https` when asked to choose a protocol.

## .gitconfig and GPG

During the bootstrap, your `.gitconfig` and gpg keys will also have been copied over to the guest os.


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

## Running Puppet

Running Puppet usually requires elevated privileges.
This can cause a bit of complication when developing modules because of bundler requirements.

To make life easier, the bootstrap process installs `rbenv sudo`. It allows you to run elevated `bundle exec` commands.

Running the bundled version of Puppet with `rbenv sudo` would look like this

```bash
rbenv sudo bundle exec puppet apply examples/example.pp --modulepath ./spec/fixtures/modules
```

For convenience, this has been wrapped in a function called `puppet-apply` and made available via the default bash profile.

```bash
puppet-apply ./spec/fixtures/manifests/site.pp --debug
```

You may see an error after running `puppet-apply` for the first time.
If this happens, just install the version of bundler mentioned in the error message.

```bash
rbenv sudo gem install bundler:2.1.4
```
