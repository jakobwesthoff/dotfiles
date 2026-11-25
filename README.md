Dotfiles
========

Personal repository of configuration files

This repository contains my personal configuration files for different
environments (mostly bash and console). It is not supposed to be used directly.
However it might serve as an example for others.

The files are split into layers: `home/base/` holds what every machine
gets, and further layers add to it, such as one per operating system
and one per machine. `layers/<name>` names the parent of each layer, so
a machine's layer pulls in the whole chain down to `base`.

`link.sh` links the files of a machine's layers into `$HOME` with
[stow](https://www.gnu.org/software/stow/manual/stow.html#Invoking-Stow).
It uses the layer named like the short hostname, or the layer given as
argument:

```sh
cd dotfiles
./link.sh
```

A file may come from one layer only; a file that differs between
machines lives in each layer that needs it, not in `base`.

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
