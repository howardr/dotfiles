# Powerline-style single-line prompt:   ~/.d/zsh  main  ›
# Loaded by zsh/prompt.zsh when DOTFILES_PROMPT=experimental (the default).
#
# Pure zsh, no plugins. The separator glyphs are Powerline symbols (U+E0B0),
# which Ghostty and Rex render from their built-in Nerd Font fallback.
# Colors are Catppuccin Mocha; tweak them here.

autoload -Uz add-zsh-hook

typeset -g PROMPT_DIR_BG='#45475a'    # surface1
typeset -g PROMPT_DIR_FG='#cdd6f4'    # text
typeset -g PROMPT_VCS_BG='#cba6f7'    # mauve (clean)
typeset -g PROMPT_DIRTY_BG='#fab387'  # peach (uncommitted changes)
typeset -g PROMPT_VCS_FG='#1e1e2e'    # base
typeset -g PROMPT_ERR_FG='#f38ba8'    # red, last command failed
typeset -g PROMPT_SEP=$'\ue0b0'

# ~/.dotfiles/zsh/functions -> ~/.d/z/functions (fish-style)
_prompt_short_pwd() {
  local dir=${(%):-%~}
  local -a parts=("${(@s:/:)dir}")
  local i out=''
  for (( i = 1; i < $#parts; i++ )); do
    if [[ ${parts[i]} == .* ]]; then
      out+="${parts[i][1,2]}/"
    else
      out+="${parts[i][1]}/"
    fi
  done
  out+=${parts[-1]}
  [[ -z $out ]] && out=/
  print -r -- "$out"
}

# Sets _prompt_vcs (label) and _prompt_vcs_dirty (0/1).
_prompt_vcs_info() {
  _prompt_vcs='' _prompt_vcs_dirty=0
  local root
  root=$(command git rev-parse --show-toplevel 2>/dev/null) || return
  if [[ -d $root/.jj ]]; then
    _prompt_vcs=jj
    return
  fi
  _prompt_vcs=$(command git symbolic-ref --short -q HEAD 2>/dev/null) ||
    _prompt_vcs=$(command git rev-parse --short HEAD 2>/dev/null)
  [[ -n $(command git status --porcelain --ignore-submodules 2>/dev/null | head -n 1) ]] &&
    _prompt_vcs_dirty=1
}

_prompt_build() {
  local last=$?
  _prompt_vcs_info

  local dir=${$(_prompt_short_pwd)//\%/%%}
  local p="%K{$PROMPT_DIR_BG}%F{$PROMPT_DIR_FG} $dir "

  if [[ -n $_prompt_vcs ]]; then
    local bg=$PROMPT_VCS_BG
    (( _prompt_vcs_dirty )) && bg=$PROMPT_DIRTY_BG
    p+="%K{$bg}%F{$PROMPT_DIR_BG}$PROMPT_SEP"
    p+="%F{$PROMPT_VCS_FG} ${_prompt_vcs//\%/%%} "
    p+="%k%F{$bg}$PROMPT_SEP"
  else
    p+="%k%F{$PROMPT_DIR_BG}$PROMPT_SEP"
  fi

  (( last != 0 )) && p+="%F{$PROMPT_ERR_FG} $last"
  _prompt_line="$p%f "
}

add-zsh-hook precmd _prompt_build
PROMPT='$_prompt_line'
RPROMPT=''
