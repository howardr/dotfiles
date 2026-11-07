# GNU ls from `brew install coreutils`, if available
if (( $+commands[gls] ))
then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -l --color"
  alias la='gls -A --color'
fi
