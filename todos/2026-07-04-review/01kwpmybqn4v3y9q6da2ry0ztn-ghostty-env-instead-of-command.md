# Ghostty: replace `command = env ...` wrapper with the `env` config option

**Area**: macos-desktop
**File**: /Users/jakob/dotfiles/.config/ghostty/config:99-100

## Current state

```
# Env on startup
command = env ENABLE_TMUX_STARTUP=true $SHELL -l
```

## Problem / opportunity

The `command` line exists only to inject one environment variable. Because
the value contains arguments, Ghostty executes it through `/bin/sh -c`,
adding a shell round-trip in front of every surface's shell. Ghostty
(since 1.2.0, installed: 1.3.1) has a dedicated `env` option for exactly
this, which lets `command` be dropped entirely; the default then resolves
the shell from `$SHELL`/passwd, and on macOS shells are launched via the
`login` command, so login-shell behavior (`-l`) is preserved.

## Grounding

`ghostty +show-config --default --docs` from the installed 1.3.1 binary
(2026-07-04):

- `env`: "Extra environment variables to pass to commands launched in a
  terminal surface. The format is `env=KEY=VALUE`. ... Available since:
  1.2.0"
- `command`: "If this is not set, a default will be looked up from your
  system. The rules for the default lookup are: `SHELL` environment
  variable, `passwd` entry (user information). ... If additional arguments
  are provided, the command will be executed using `/bin/sh -c`"
- `abnormal-command-exit-runtime` docs: "On macOS, we allow any exit code
  because of the way shell processes are launched via the login command."
  (confirms macOS launches the shell via `login`, i.e. as a login shell,
  without needing an explicit `-l`)

## Proposed change

```
# Env on startup
env = ENABLE_TMUX_STARTUP=true
```

and remove the `command` line. Verify after a Ghostty restart that the
tmux auto-start (driven by ENABLE_TMUX_STARTUP in the zsh config) still
triggers and that the shell is a login shell (`echo $0` → `-zsh`).
