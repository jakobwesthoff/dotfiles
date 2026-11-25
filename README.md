Dotfiles
========

Personal repository of configuration files

This repository contains my personal configuration files for different
environments (mostly bash and console). It is not supposed to be used directly.
However it might serve as an example for others.

The file structure is supposed to be *installed* using
[stow](https://www.gnu.org/software/stow/manual/stow.html#Invoking-Stow):

```sh
cd dotfiles
setup/checkout_dependencies.sh
stow .
```

`setup/checkout_dependencies.sh` clones the repositories the dotfiles
rely on and has to run before `stow`.

In order to configure a completely new machine including installing software
(highly opinionated and tailored to my needs), run the script for its
platform after checkout:

```sh
cd dotfiles
setup/macos/initial_macos_setup.sh    # on a Mac
setup/fedora/initial_fedora_setup.sh  # on Fedora
```

Everything used for setting up a machine lives in `setup/`, which stow
ignores. See [setup/README.md](setup/README.md).
