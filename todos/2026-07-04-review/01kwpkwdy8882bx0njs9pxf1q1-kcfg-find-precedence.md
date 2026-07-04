# kcfg(): find `-o` precedence bug — `-type f` does not apply to `*.yml` matches

**Area**: shell-env
**File**: /Users/jakob/dotfiles/.zshrc.d/050_kubectl.sh:348

## Current state

```zsh
done < <(find "$search_dir" -maxdepth 1 -mindepth 1 -type f -name "*.yaml" -o -name "*.yml")
```

## Problem

In `find`, implicit `-a` binds tighter than `-o`, so this parses as
`( -type f -a -name "*.yaml" ) -o ( -name "*.yml" )`. The `-type f` test only
constrains the `.yaml` branch; a *directory* named `*.yml` inside `~/.kube`
would be offered in the kubeconfig picker and, if selected, exported as
`KUBECONFIG` pointing at a directory.

## Grounding

Demonstrated with a test tree containing files `a.yaml`, `b.yml` and a
directory `sub.yml`:

```
$ find findtest -maxdepth 1 -mindepth 1 -type f -name "*.yaml" -o -name "*.yml"
findtest/b.yml
findtest/a.yaml
findtest/sub.yml        <- directory matched
$ find findtest -maxdepth 1 -mindepth 1 -type f \( -name "*.yaml" -o -name "*.yml" \)
findtest/b.yml
findtest/a.yaml
```

## Proposed change

```zsh
find "$search_dir" -maxdepth 1 -mindepth 1 -type f \( -name "*.yaml" -o -name "*.yml" \)
```

Side note in the same file: line 1 reads `# INCLUDE GUARD END` but sits at the
*top* of the file (the matching `fi` at line 374-375 carries the same "END"
comment); the top one should say something like `# INCLUDE GUARD BEGIN`.
