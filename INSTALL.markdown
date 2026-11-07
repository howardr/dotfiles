# New machine setup

Steps for a fresh Mac (Apple Silicon). Most of the work happens in
`script/bootstrap`; everything else here is either a secret or a manual
choice.

## 1. Install Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

via [brew.sh](https://brew.sh/). You can skip the "next steps" it prints
about adding `brew` to your `PATH`. `homebrew/path.zsh` handles that once the
dotfiles are installed.

## 2. Install your SSH key

Copy your private key to `~/.ssh/id_ed25519`, then:

```sh
mkdir -p ~/.ssh
chmod 700 ~/.ssh
chmod 400 ~/.ssh/id_ed25519
```

Create `~/.ssh/config`:

```
Host *
  AddKeysToAgent yes
  HashKnownHosts yes
  VisualHostKey yes
```

## 3. Install the dotfiles

```sh
git clone git@github.com:howardr/dotfiles.git ~/.dotfiles
~/.dotfiles/script/bootstrap
```

Bootstrap will:

- ask for your git name and email (creates `git/gitconfig.symlink`, which is
  not tracked)
- create `~/code`
- link everything into place (`script/link`)
- run `dot`, which `brew bundle`s the [Brewfile](Brewfile) (zsh, asdf, Docker
  + Colima, Ghostty, cmux, VS Code and its `code` command, gcloud, ...),
  installs oh-my-zsh and zsh-autosuggestions, and installs the asdf runtimes
  from `~/.tool-versions`

To preview without changing anything: `script/bootstrap --dry-run`.

Don't use the oh-my-zsh installer from ohmyz.sh. It replaces `~/.zshrc`,
which unlinks the dotfiles. `dot` installs oh-my-zsh with a plain `git clone`
instead.

Then open a new terminal.

## 4. Optional: macOS defaults

```sh
dot --defaults
```

Applies `osx/set-defaults.sh` (fast key repeat, Finder list view, and so on).
Some settings don't take effect until you log out and back in.

## 5. Fonts

Download the saved fonts (Dank Mono, Inconsolata) from
[Dropbox/Fonts](https://www.dropbox.com/home/Fonts) and install them. Ghostty
and VS Code are already configured to use Dank Mono.

## 6. OpenCode + cmux

```sh
cmux hooks setup
```

On a work machine, also create the work OpenCode config. See
[opencode/README.md](opencode/README.md).

## 7. Machine-specific shell settings

Put anything specific to this machine (work tools, `OPENCODE_CONFIG`, ...) in
`~/.localrc`. It's sourced by the shell and never committed.

## 8. Optional: `sudo` without a password

*I was convinced that I should go ahead and do this because once my computer
is unlocked I am already f'd.*

Run `EDITOR=vim sudo visudo` and change

```
%admin ALL=(ALL) ALL
```

to

```
%admin ALL=(ALL) NOPASSWD: ALL
```

via [stackexchange.com](https://apple.stackexchange.com/questions/257813/enable-sudo-without-a-password-on-macos)
