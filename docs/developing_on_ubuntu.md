# Developing on Ubuntu

We're going to use `Ubuntu 20.04` in this example so lets start by changing directory and booting up our `vagrant` machine.

```bash
cd ubuntu/2004
vagrant up
```

After the machine starts it will get bootstrapped for development. See the [Vagrantfile](ubuntu/2004/Vagrantfile) for more information.

Lets start by accessing our new machine. For this, you'll need `vscode` and the `Visual Studio Code Remote - SSH` extension.

Follow [this great guide](https://medium.com/@lopezgand/connect-visual-studio-code-with-vagrant-in-your-local-machine-24903fb4a9de) to get started.

> ✨ **Tip!** By default, the ssh configuration from `vagrant ssh-config` will specify the Host as default. Change this to something more meaningful, like `vagrant`.

Once you have a session established with your remote machine, open a new terminal and clone your module.

```bash
git clone https://github.com/puppetlabs/puppetlabs-motd
cd puppetlabs-motd
```

Open vscode and start a new terminal.

```bash
code .
```

Debugging requires a few extra gems. For this we generally create a local Gemfile so that we don't have add any unnecessary dependencies in to our main Gemfile.

```bash
cat << EOF > ./gemfile.local
  gem 'fuubar'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
EOF
```

Now run `bundle install` to pull down dependencies.

```bash
bundle install
```

Once the dependencies have installed we need to initialize the module for development.

```bash
bundle exec rake spec_prep
```

Underneath the `spec/fixtures/` you should now have the following directories:

* modules: `spec/fixtures/modules`
* manifests: `spec/fixtures/manifests`

You can define test classes in `spec/fixtures/manifests/site.pp`

## Running Puppet

Running Puppet requires the user to be root, this can cause a bit of complication when switching between users.

To make life easier, the bootstrap process installs rbenv sudo. It allows you to run `bundle exec `commands with sudo.

All that you need to do is prefix any `bundle exec` commands with `rbenv sudo` as follows:

```bash
rbenv sudo bundle exec puppet apply ./spec/fixtures/manifests/site.pp --modulepath ./spec/fixtures/modules/ --debug
```
