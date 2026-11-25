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

[Scriptisto](https://github.com/igor-petruk/scriptisto) is needed for some
of the scripts in this repository. Please install it in conjunction with
[Rust](https://rustup.rs) if you want to use them.

In order to configure a completely new machine including installing software
(highly opinionated and tailored to my needs), run the following script after
checkout: 

```sh
cd dotfiles
setup/macos/initial_macos_setup.sh
```

Everything used for setting up a machine lives in `setup/`, which stow
ignores. See [setup/README.md](setup/README.md).
