# dotfiles

My dotfiles. Originally forked from
[Holman's dotfiles](https://github.com/holman/dotfiles) (which in turn grew
out of [Ryan Bates'](https://github.com/ryanb/dotfiles)), and since diverged.
The topic-folder layout is still his; read
[his post](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/) for
the philosophy.

## install

New machine: see [INSTALL.markdown](INSTALL.markdown). The short version:

```sh
git clone git@github.com:howardr/dotfiles.git ~/.dotfiles
~/.dotfiles/script/bootstrap
```

## keeping a machine up to date: `dot`

`dot` (in `bin/`, so it's on your `PATH`) is the one command to run on any
machine, any time. It's safe to re-run.

1. `git pull`s this repo
2. links everything into place (`script/link`)
3. installs Homebrew if needed and `brew bundle`s the [Brewfile](Brewfile)
4. installs/updates oh-my-zsh and zsh-autosuggestions
5. installs asdf plugins and the versions in `~/.tool-versions`

```sh
dot              # the usual
dot --upgrade    # also upgrade outdated Homebrew packages
dot --defaults   # also apply macOS defaults (osx/set-defaults.sh)
dot --no-brew    # skip Homebrew (quick sync of links and oh-my-zsh)
dot --edit       # open this repo in $EDITOR
```

A failed step is reported and the rest keep going; `dot` exits non-zero if
anything failed.

## topical

Everything's built around topic areas. To add one (say, "java"), add a `java/`
folder and put files in it. What happens to a file depends on its name:

| File | What happens |
| --- | --- |
| `topic/*.zsh` | Sourced into every shell |
| `topic/path.zsh` | Sourced first, to set up `$PATH` (`homebrew/path.zsh` goes before all others) |
| `topic/completion.zsh` | Sourced last, after completion is initialized |
| `topic/*.symlink` | Linked into `~` as a dotfile: `git/gitignore.symlink` becomes `~/.gitignore` |
| `topic/links` | Links files anywhere under `~`, such as `~/.config` or `~/Library` (see below) |
| `topic/_name` | A zsh completion function (every topic folder is on `fpath`) |
| `bin/*` | On your `PATH` |
| `functions/*` | Autoloaded zsh functions |

### `links` files

For anything that doesn't live at `~/.something`, add a `links` file to the
topic folder with one `source -> destination` per line. The source is relative
to the topic folder and the destination is relative to `~`. Spaces are fine.
`#` starts a comment.

```
# ghostty/links
config -> .config/ghostty/config

# vscode/links
settings.json -> Library/Application Support/Code/User/settings.json
```

Link individual files rather than whole directories. Apps like OpenCode and
cmux write their own files into their config directories, and you don't want
those ending up in this repo.

### `script/link`

`script/link` creates every link from `*.symlink` and `links` files. `dot` and
`script/bootstrap` both run it, and you can also run it on its own:

```sh
script/link --dry-run   # show what would change
script/link
```

- Links that are already correct are left alone.
- If a real file is in the way, it asks: skip, overwrite, or back up (each
  with an "all" variant). When nothing is there to answer, it skips and warns.
- Links that point into this repo at a file that no longer exists (because
  you deleted or renamed it) are removed. Links that point anywhere else are
  never touched.

## shell

`~/.zshrc` links to `zsh/zshrc.symlink`, which loads things in this order:

1. `~/.localrc`, for machine-specific settings that aren't tracked (see below)
2. every `path.zsh`
3. [oh-my-zsh](https://ohmyz.sh), with no theme (the prompt lives in
   `zsh/prompt.zsh`) and the `gcloud` and `zsh-autosuggestions` plugins. If
   oh-my-zsh isn't installed, the shell still works; it just runs `compinit`
   on its own.
4. every other `*.zsh`. These load after oh-my-zsh, so our aliases, options and
   key bindings win.
5. every `completion.zsh`

`$DOTFILES` points at this repo. `$ZSH` belongs to oh-my-zsh.

`~/.localrc` is for anything specific to one machine that shouldn't be in a
public repo, such as work-only tools and config paths. It is never committed.

## secrets

Don't `export` API tokens from `~/.localrc` or paste them on the command line.
Exported tokens are visible to every process you start (including package
install scripts), and inline ones end up in `~/.zsh_history`. Instead, keep
them in the macOS Keychain and hand them to one command at a time:

```sh
secret-set GITHUB_TOKEN                    # prompts for the value, stores it in Keychain
with-secret GITHUB_TOKEN -- gh api user    # runs one command with GITHUB_TOKEN set
with-secret A_TOKEN B_TOKEN -- some-cmd    # multiple secrets
secret-rm GITHUB_TOKEN                     # delete it
```

`with-secret` exports the values in a subshell, so they don't persist in your
shell and never appear in history. Secrets are stored as generic passwords
named `env/NAME` in the login Keychain. The functions live in `functions/`.

## ideas

[TODO.markdown](TODO.markdown) lists improvements I've considered but put off.
