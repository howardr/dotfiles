# Terminal & Code Setup

Parts of this reused from https://medium.com/ayuth/iterm2-zsh-oh-my-zsh-the-most-power-full-of-terminal-on-macos-bdb2823fb04c

## Install iTerm 2

Go to https://www.iterm2.com/downloads.html

## Install SSH Keys

Create `.ssh` directory

```
mkdir ~/.ssh
```
*Paste in private key to `~/.ssh/id_ed25519`*

Change permisions

```
chmod 400 ~/.ssh/id_ed25519
```

## Add SSH config

Paste below config to `~/.ssh/config`

```
Host *
  AddKeysToAgent yes
  HashKnownHosts yes
  VisualHostKey yes
```

## Install Homebrew

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

via [brew.sh](https://brew.sh/)

Make sure to follow instructins as end of the install process to add `brew` to PATH

## Install zsh

```
brew install zsh
```

via [GitHub](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH#how-to-install-zsh-on-many-platforms)

## Install oh-my-zsh

```
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

via [ohmyz.sh](https://ohmyz.sh/#install)

## Install dotfiles

```
git clone git@github.com:howardr/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

## Install zsh-autosuggestions

```
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

via [GitHub](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#oh-my-zsh)

## Install rbenv

```
brew install rbenv
```

via [GitHub](https://github.com/rbenv/rbenv#installation)

## Enable `sudo` without password

*I was convinced that I should go ahead and do this because once my computer is unlocked I am already f'd.*

Open a terminal, run `EDITOR=vim sudo visudo`

Edit the line:

```
%admin ALL=(ALL) ALL
```

To say:

```
%admin ALL=(ALL) NOPASSWD: ALL
```

via [stackexchange.com](https://apple.stackexchange.com/questions/257813/enable-sudo-without-a-password-on-macos)

## Setup code

```
mkdir -p ~/code
```

## Install Fonts

Download saved fonts from [Dropbox/Fonts](https://www.dropbox.com/home/Fonts)

## Update iTerm settings

From Preferences

 * Appearance > General > Theme > `Minimal`
 * Appearance > Windows > `Hide scrollbars`
 * Appearaace > Dimming > `Dim background windows`
 * Appearance > Dimming > `Dimming affects only text, not backround.`
 * Profiles > Default > Colors > Select `Dark Mode`
 * Profiles > Default > Colors > Uncheck "Use different colors for light mode and dark mode"
 * Profiles > Default > Text > Font > `Dank Mono` at `16pt`
 * Profiles > Default > Window > Transparency > `10`
 * Profiles > Default > Window > Blur > `20`

## Download VSCode

Go to https://code.visualstudio.com/

## Update VSCode settings

 * Font Size: `16`
 * Font Family: `'Dank Mono', Inconsolata, Menlo, Monaco, 'Courier New', monospace`
 * Tab Size: `2` 😬
 * Render Whitespace: `trailing`

## Add `code` to PATH

 * In VSCode type `command` + `shift` + `p`
 * Type `code path` in dialog
 * Select `Shell Command: Install 'code' command in PATH`
