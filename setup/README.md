Setup
=====

Scripts and package lists for setting up a machine. Stow ignores this
directory (see `.stow-local-ignore`), so none of it gets linked into
`$HOME`.

```
setup/
├── checkout_dependencies.sh     shared by all platforms
└── macos/
    ├── initial_macos_setup.sh   full setup of a new Mac
    ├── Brewfile                 Homebrew packages, casks and fonts
    └── update-brewfile-from-system
```

checkout_dependencies.sh
------------------------

Clones or updates the repositories the dotfiles rely on into `$HOME`
(colorizer, prettytable, zgenom, and on macOS yabai-center-single). It
has to run before `stow`, because it creates `~/bin` as a real
directory. Without that, stow would link `~/bin` as a whole to
`dotfiles/bin`, and anything else placed in `~/bin` would end up in the
repository.

```sh
~/dotfiles/setup/checkout_dependencies.sh
```

macOS
-----

`initial_macos_setup.sh` sets up a new Mac from scratch: checks
prerequisites, installs Homebrew, clones and stows the dotfiles,
installs the `Brewfile` and the Mac App Store apps, starts the services
and writes the macOS defaults. It is opinionated and tailored to one
person's machines.

```sh
~/dotfiles/setup/macos/initial_macos_setup.sh
```

`update-brewfile-from-system` reconciles the `Brewfile` with what is
installed on the running Mac. It shows a checklist of all packages
installed on request, removes unchecked entries from the `Brewfile`
and appends newly checked ones under an "Unsorted" section. It reads
the `Brewfile` from the current directory:

```sh
cd ~/dotfiles/setup/macos
./update-brewfile-from-system
```
