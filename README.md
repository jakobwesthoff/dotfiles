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
stow .
```

Most of the needed dependencies can be installed using the `checkout_dependencies.sh`.

[Scriptisto](https://github.com/igor-petruk/scriptisto) is needed for some
of the scripts in this repository. Please install it in conjunction with
[Rust](https://rustup.rs) if you want to use them.
