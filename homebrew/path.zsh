# Homebrew (Apple Silicon). Sets PATH, MANPATH, INFOPATH, HOMEBREW_PREFIX and
# adds Homebrew's zsh completions to fpath. Loaded before every other path.zsh.
if [[ -x /opt/homebrew/bin/brew ]]
then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi
