Setup
=====

Scripts and package lists for setting up a machine. Stow ignores this
directory (see `.stow-local-ignore`), so none of it gets linked into
`$HOME`.

```
setup/
├── checkout_dependencies.sh     shared by all platforms
├── macos/
│   ├── initial_macos_setup.sh   full setup of a new Mac
│   ├── Brewfile                 Homebrew packages, casks and fonts
│   └── update-brewfile-from-system
└── fedora/
    ├── initial_fedora_setup.sh  full setup of a Fedora machine
    ├── packages.txt             dnf packages
    └── tools.txt                tools Fedora does not package
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
and writes the macOS defaults. It is opinionated and tailored to my
machines.

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

Fedora
------

`initial_fedora_setup.sh` sets up a Fedora machine I work on over SSH,
such as a headless server: upgrades the system, enables RPM Fusion,
installs the development tools group and `packages.txt`, sets up Rust
with rustup, installs the tools from `tools.txt`, nvm and Claude Code,
makes zsh the login shell, limits sshd to keys, creates an SSH key for
GitHub, turns on automatic security updates and clones the dotfiles.
It does not stow them; it prints how to do that at the end. Run it from
a checkout of this repository, since it reads its lists from its own
directory:

```sh
git clone https://github.com/jakobwesthoff/dotfiles.git ~/dotfiles
~/dotfiles/setup/fedora/initial_fedora_setup.sh
```

`packages.txt` lists dnf packages, one per line. `tools.txt` lists the
tools Fedora does not package, each line naming the installer to use
(`cargo`, `go` or `npm`) followed by its arguments.
