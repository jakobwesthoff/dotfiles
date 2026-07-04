# makeitso() re-runs an ancient history entry with sudo instead of the last command

**Area**: shell-env
**File**: /Users/jakob/dotfiles/.zshrc.d/050_functions.sh:47-49

## Current state

```bash
# In honor to Star-Trek
makeitso() {
    sudo $(history 2 | head -n 1 | sed -e 's@^[0-9]\+\s\+@@')
}
```

## Problem

`history 2` is a **bash** idiom ("show the last 2 entries"). In zsh,
`history` is `fc -l`, and a positive numeric argument is the *first event
number* to list: `history 2` lists everything from event #2 to the end of
history. `head -n 1` then picks event #2 — one of the oldest entries in the
session's history (with `HISTSIZE=25000` loaded from `~/.zsh_history`, an
essentially arbitrary old command). The function then executes that arbitrary
command **with sudo**. This is both broken and dangerous.

## Grounding

Tested with a controlled 3-entry history file:

```
$ zsh -c 'HISTFILE=...; fc -R; history 2 | head -5'
    2  second_command
    3  third_command        <- lists FROM event 2, not the last 2
$ zsh -c '...; fc -ln -1'
third_command               <- (fc -ln -1 lists up to the last event)
```

`history 2` returned events starting at #2; it does not return the previous
command.

## Proposed change

Use the zsh-native form for "previous command":

```zsh
makeitso() {
    sudo zsh -c "$(fc -ln -1)"
}
```

(`fc -ln -1` prints exactly the most recent history entry without event
numbers; running it through `zsh -c` preserves quoting/pipes instead of
relying on word splitting of an unquoted `$(...)`.)
