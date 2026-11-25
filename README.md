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
(highly opinionated and tailored to my needs), run `setup.sh` after
checkout. It works with the same layers as `link.sh`, lets me pick the
setup steps of all of them in a checklist and links the dotfiles as its
last step:

```sh
cd dotfiles
./setup.sh
```

A new machine needs its own layer first: `layers/<short hostname>`
holding the name of its parent, such as `macos` or `fedora`.

Everything used for setting up a machine lives in `setup/`. See
[setup/README.md](setup/README.md).
