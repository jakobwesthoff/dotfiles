# Reference claims `--repo` works for API calls, but `glab api` has no `--repo` flag

**Skill**: glab-mr-review
**File**: `/Users/jakob/dotfiles/.claude/skills/glab-mr-review/references/gitlab-api-comments.md`, section "Project ID Encoding" (last paragraph)

## Current state

> Alternatively, use `--repo` where supported, but the Discussions and Notes
> endpoints require the encoded project path in the URL.

## Problem / opportunity

`glab api` accepts no `--repo` flag at all, so "use `--repo` where supported"
is misleading in a reference whose every command is `glab api`. A model
following this hint may run `glab api ... --repo group/project` and fail.
The section also omits two genuinely useful `glab api` facts: the
`:fullpath` placeholder (auto-URL-encoded project path of the current git
directory) and host resolution via `--hostname`.

## Grounding

`glab api --help` output (glab 1.105.0, run locally 2026-07-04):

- Flag list contains only: `-F --field`, `--form`, `-H --header`, `-h --help`,
  `--hostname`, `-i --include`, `--input`, `-X --method`, `--output`,
  `--paginate`, `-f --raw-field`, `--silent`. No `--repo`.
- "When used in the endpoint argument, these placeholder values are replaced
  with values from the repository of the current directory: `:branch`,
  `:fullpath`, `:group`, `:id`, `:namespace`, `:repo`, `:user`, `:username`."
- Built-in example: `glab api projects/:fullpath/releases`.
- "If the current directory is a Git directory, this command uses the GitLab
  authenticated host in the current directory. Otherwise, `gitlab.com` is
  used. To override the GitLab hostname, use `--hostname`."

(`--repo` does exist on `glab mr` subcommands such as `view`/`diff`; only
`glab api` lacks it.)

## Proposed change

Replace the quoted sentence with accurate guidance:

- `glab api` has no `--repo` flag.
- When the shell's working directory is inside the target repository, use
  `projects/:fullpath/merge_requests/<IID>/...`; glab substitutes
  `:fullpath` with the URL-encoded project path automatically.
- When targeting another project, URL-encode the path manually
  (`group/project` -> `group%2Fproject`), and pass `--hostname <host>` if the
  MR lives on a different GitLab host than the current directory's
  authenticated one.
