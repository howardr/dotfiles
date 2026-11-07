# TODO

Ideas that were discussed during the 2026 cleanup but deferred. Nothing here
is required; each item is independent.

## Machine-local overrides

The rule: the repo holds shared defaults. Anything specific to one machine
(identity, secrets, employer tools) lives in a file in `$HOME` next to the real
config, never in the repo, and is pulled in by that tool's own include
mechanism. `~/.localrc` and `~/.config/opencode/work.jsonc` already work this
way.

- [ ] **Untracked `~/.zshrc` loader.** Today `~/.zshrc` is a symlink into the
  repo, so every installer that "adds itself to your shell" (opencode,
  Cloudflare tooling, etc.) edits a tracked file. Instead, have bootstrap
  generate a small untracked `~/.zshrc`:

  ```zsh
  source ~/.dotfiles/zsh/zshrc
  # installers append below this line; move anything worth keeping into the repo
  ```

  The tracked file must not end in `.zsh`, or the `**/*.zsh` loader will source
  it into itself.

- [ ] **`~/.gitconfig.local`.** Move `[user]` and machine-specific `[include]`s
  (e.g. the WARP certs include) into an untracked `~/.gitconfig.local`, add
  `[include] path = ~/.gitconfig.local` to `git/gitconfig.symlink`, and start
  tracking `git/gitconfig.symlink` (it is currently gitignored, so none of the
  git config is version controlled). Upstream holman/dotfiles does exactly
  this with `git/gitconfig.local.symlink.example`.

- [ ] **`~/.Brewfile.local`.** Work-only formulae (`cf-*`, `cfsetup`, `vault`,
  `harness-proxy`, ...) in an untracked Brewfile that `dot` also runs with
  `brew bundle --file ~/.Brewfile.local`.

- [ ] **Ghostty local include.** Add `config-file = ?<path>` (the `?` makes it
  optional) to `ghostty/config` for per-machine tweaks. Verify how Ghostty
  resolves relative paths first.

- [ ] **`ssh/config` in the repo** with `Include ~/.ssh/config.local` for
  host-specific entries, replacing the copy/paste step in INSTALL.

- [ ] **Document the convention** in README with a table of tracked file vs
  local file vs how it's loaded.

## Shell

- [ ] **Faster prompt.** `zsh/prompt.zsh` runs `git status`, `git symbolic-ref`
  (twice) and `git cherry` on every prompt. Fine in small repos, laggy in big
  ones. Options: zsh's built-in `vcs_info`, or a single
  `git status --porcelain=v2 --branch` call parsed once per prompt.
