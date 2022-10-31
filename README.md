# Puppet development boxes

A collection of vagrant boxes & guides that will level up your Puppet module development.

## Development guides

These documents will help you get prepared for Puppet module development.
They specifically focus on the development of Ruby types and providers.
However, the environments will also handle manifest-based development.

### Requirements

* [Make](https://www.gnu.org/software/make/)
* [Vagrant](https://www.vagrantup.com/downloads)
* [Bolt](https://puppet.com/docs/bolt/latest/bolt_installing.html)
* [vagrant-bolt Vagrant plugin](https://github.com/oscar-stack/vagrant-bolt)

### Environment setup

* [Developing on Windows](docs/developing_on_windows.md)
* [Developing on Ubuntu](docs/developing_on_ubuntu.md)

### Setting up for remote development with vscode

You are going to need `vscode` and the `Visual Studio Code Remote - SSH` extension.

Follow [this great guide](https://medium.com/@lopezgand/connect-visual-studio-code-with-vagrant-in-your-local-machine-24903fb4a9de) to get started.

> ✨ **Tip!** By default, the ssh configuration from `vagrant ssh-config` will specify the Host as default. Change this to something more meaningful, like `vagrant`.

### Debugging

* [Beginners guide to Pry](https://medium.com/@eddgr/the-absolute-beginners-guide-to-using-pry-in-ruby-b08681558fa6)
* [Pry cheat sheet](https://gist.github.com/lfender6445/9919357)
