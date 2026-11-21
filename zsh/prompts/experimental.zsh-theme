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
typeset -g PROMPT_DIRTY_MARK='●'      # uncommitted changes
typeset -g PROMPT_AHEAD_MARK='↑'      # commits not yet pushed
typeset -g PROMPT_BEHIND_MARK='↓'     # commits not yet pulled

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

# Sets _prompt_vcs (label), _prompt_vcs_dirty (0/1), and _prompt_ahead /
# _prompt_behind (commits vs. upstream), from a single git status call.
_prompt_vcs_info() {
  _prompt_vcs='' _prompt_vcs_dirty=0 _prompt_ahead=0 _prompt_behind=0

  local d=$PWD
  while [[ -n $d ]]; do
    if [[ -d $d/.jj ]]; then
      _prompt_vcs=jj
      return
    fi
    d=${d%/*}
  done

  local line oid ab
  local -a st
  st=("${(@f)$(command git status --porcelain=v2 --branch --ignore-submodules 2>/dev/null)}")
  [[ -n ${st[1]} ]] || return

  for line in $st; do
    case $line in
      ('# branch.oid '*)  oid=${line#'# branch.oid '} ;;
      ('# branch.head '*) _prompt_vcs=${line#'# branch.head '} ;;
      ('# branch.ab '*)
        ab=${line#'# branch.ab '}
        _prompt_ahead=${${ab%% *}#+}
        _prompt_behind=${${ab##* }#-} ;;
      ('#'*) ;;
      (*) _prompt_vcs_dirty=1 ;;
    esac
  done
  [[ $_prompt_vcs == '(detached)' ]] && _prompt_vcs=${oid[1,7]}
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
    local label=${_prompt_vcs//\%/%%}
    (( _prompt_vcs_dirty )) && label+=" $PROMPT_DIRTY_MARK"
    (( _prompt_ahead ))     && label+=" $PROMPT_AHEAD_MARK$_prompt_ahead"
    (( _prompt_behind ))    && label+=" $PROMPT_BEHIND_MARK$_prompt_behind"
    p+="%F{$PROMPT_VCS_FG} $label "
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
