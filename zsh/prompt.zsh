# Prompts live in zsh/prompts/*.zsh-theme (not *.zsh, so zshrc doesn't
# auto-source them all). Pick one with DOTFILES_PROMPT, e.g. in ~/.localrc,
# or try one out with: DOTFILES_PROMPT=classic zsh

source $DOTFILES/zsh/prompts/${DOTFILES_PROMPT:-experimental}.zsh-theme
