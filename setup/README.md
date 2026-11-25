Setup
=====

Everything `setup.sh` and `link.sh` in the repository root run. Each
layer from `layers/` may have a directory here; a layer without one has
nothing to set up.

```
setup/
├── lib.sh                      helpers for setup.sh, link.sh, presetups and steps
├── checkout_dependencies.sh    repositories the dotfiles rely on (run by link.sh)
├── base/
│   └── setup.d/                steps for every machine
├── macos/
│   ├── presetup.sh             Xcode tools, Homebrew, bash, dialog, git, stow
│   ├── setup.d/
│   ├── Brewfile                Homebrew packages, casks, fonts, App Store apps
│   └── update-brewfile-from-system
└── fedora/
    ├── presetup.sh             dialog, git, stow
    ├── setup.d/
    ├── packages.txt            dnf packages
    ├── tools.txt               tools Fedora does not package
    └── xterm-ghostty.terminfo
```

How setup.sh runs
-----------------

1. It finds the machine's layer (the argument, otherwise the one named
   like the short hostname) and the chain of parents down to `base`.
2. It runs the `presetup.sh` of every layer in the chain, `base` first.
   A presetup installs what the rest needs before anything can be
   chosen: a current bash and `dialog`. This part runs on the system's
   own bash, which on a fresh Mac is bash 3.2, so `setup.sh`, `lib.sh`
   and the presetups avoid newer bash features.
3. It starts itself again in the current bash and shows all steps of all
   layers in a `dialog` checklist, everything preselected.
4. It runs the chosen steps in order of their number; for the same
   number, `base` before the OS layer before the host layer. A failing
   step stops the run.

The last step, `base/setup.d/900-link.sh`, links the dotfiles with
`link.sh`.

Writing a step
--------------

A step is a file `setup.d/NNN-name.sh` in a layer's directory. `setup.sh`
sources it in a subshell with `set -euo pipefail`, working directory
`setup/<layer>/` and the helpers from `lib.sh` (`section`, `info`, `ok`,
`skip`, `warn`, `fail`, `ask`, `list_entries`). Steps may use bash 4 and
newer.

```bash
# shellcheck shell=bash
# description: Install the dnf packages from packages.txt

mapfile -t packages < <(list_entries packages.txt)
sudo dnf install -y "${packages[@]}"
ok "${#packages[@]} packages installed"
```

- The `# description:` line is what the checklist shows.
- A step checks before it acts, so running `setup.sh` again is safe and
  is the way to bring a machine up to date.
- Numbers group the steps: 0xx checks and updates, 1xx packages, 2xx
  languages and toolchains, 3xx tools, 5xx services and security, 6xx
  lock screen and login, 7xx shell, 8xx OS settings, 9xx linking.

Package lists
-------------

`macos/Brewfile` is installed with `brew bundle`.
`macos/update-brewfile-from-system` reconciles it with what is installed
on the running Mac: it shows a checklist of all packages installed on
request, removes unchecked entries and appends newly checked ones under
an "Unsorted" section. It reads the `Brewfile` from the current
directory:

```sh
cd ~/dotfiles/setup/macos
./update-brewfile-from-system
```

`fedora/packages.txt` lists dnf packages, one per line. `fedora/tools.txt`
lists the tools Fedora does not package, each line naming the installer
to use (`cargo`, `go` or `npm`) followed by its arguments.
