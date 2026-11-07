# Shared helpers for script/bootstrap, script/link and bin/dot.
# Bash 3.2 compatible (macOS /bin/bash). Source it; don't run it.

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}"
DRY_RUN="${DRY_RUN:-false}"

info () {
  printf "  [ \033[00;34m..\033[0m ] %b\n" "$1"
}

user () {
  printf "  [ \033[0;33m??\033[0m ] %b " "$1"
}

success () {
  printf "  [ \033[00;32mOK\033[0m ] %b\n" "$1"
}

warn () {
  printf "  [ \033[0;33m!!\033[0m ] %b\n" "$1"
}

fail () {
  printf "  [\033[0;31mFAIL\033[0m] %b\n" "$1"
  echo ''
  exit 1
}

# Pretty-print a path with $HOME shortened to ~
tildify () {
  case "$1" in
    "$HOME"/*) printf '~/%s' "${1#"$HOME"/}" ;;
    *) printf '%s' "$1" ;;
  esac
}

# Run a command, or just print it in dry-run mode.
run () {
  if [ "$DRY_RUN" = "true" ]
  then
    printf "         would run: %s\n" "$*"
  else
    "$@"
  fi
}

# link_file SRC DST
#
# Symlinks SRC to DST. Safe to run repeatedly:
#   - DST already points at SRC     -> nothing to do (silent)
#   - DST missing                   -> link it (creating parent dirs)
#   - DST is something else         -> ask: skip / overwrite / backup
#     (with "all" variants). Non-interactive runs skip and warn.
#
# Uses the globals overwrite_all / backup_all / skip_all so the "all" answers
# carry across calls; reset them with reset_link_answers.
reset_link_answers () {
  overwrite_all=false backup_all=false skip_all=false
}
reset_link_answers

LINKED_COUNT=0
OK_COUNT=0
FAILED_COUNT=0

link_file () {
  local src="$1" dst="$2"
  local overwrite=false backup=false skip=false action=

  # Never operate on $HOME itself or outside of it.
  case "$dst" in
    "$HOME"|"$HOME"/|"$HOME"/.|"$HOME"/./) fail "refusing to link over \$HOME (from $(tildify "$src"))" ;;
    "$HOME"/*) ;;
    *) fail "refusing to link outside \$HOME: $dst" ;;
  esac

  if [ ! -e "$src" ]
  then
    warn "missing source $(tildify "$src"), not linking $(tildify "$dst")"
    return 0
  fi

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]
  then
    OK_COUNT=$((OK_COUNT + 1))
    return 0
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]
  then
    if [ "$DRY_RUN" = "true" ]
    then
      warn "would ask: $(tildify "$dst") exists and is not a link to $(tildify "$src")"
      return 0
    fi

    if [ "$overwrite_all" = "false" ] && [ "$backup_all" = "false" ] && [ "$skip_all" = "false" ]
    then
      if [ ! -t 0 ]
      then
        warn "skipped $(tildify "$dst"): already exists (run script/link in a terminal to resolve)"
        return 0
      fi

      user "$(tildify "$dst") already exists, what do you want to do?\n         [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
      read -r -n 1 action
      echo ''

      case "$action" in
        o ) overwrite=true;;
        O ) overwrite_all=true;;
        b ) backup=true;;
        B ) backup_all=true;;
        S ) skip_all=true;;
        * ) skip=true;;
      esac
    fi

    if [ "$skip" = "true" ] || [ "$skip_all" = "true" ]
    then
      success "skipped $(tildify "$dst")"
      return 0
    fi

    # Real directories are always backed up, never deleted, even with
    # "overwrite all".
    if [ -d "$dst" ] && [ ! -L "$dst" ]
    then
      backup=true
    fi

    if [ "$backup" = "true" ] || [ "$backup_all" = "true" ]
    then
      local bak="${dst}.backup"
      [ -e "$bak" ] || [ -L "$bak" ] && bak="${dst}.backup.$(date +%Y%m%d%H%M%S)"
      mv "$dst" "$bak" || return 1
      success "moved $(tildify "$dst") to $(tildify "$bak")"
    elif [ "$overwrite" = "true" ] || [ "$overwrite_all" = "true" ]
    then
      rm -f "$dst" || return 1
      success "removed $(tildify "$dst")"
    fi

    if [ -e "$dst" ] || [ -L "$dst" ]
    then
      warn "$(tildify "$dst") is still in the way; not linking"
      return 1
    fi
  fi

  if [ "$DRY_RUN" = "true" ]
  then
    info "would link $(tildify "$dst") -> $(tildify "$src")"
    return 0
  fi

  mkdir -p "$(dirname "$dst")" || return 1
  ln -s "$src" "$dst" || return 1
  LINKED_COUNT=$((LINKED_COUNT + 1))
  success "linked $(tildify "$dst") -> $(tildify "$src")"
}

# Strip leading/trailing whitespace (including \r from CRLF files).
trim () {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

# topic/*.symlink -> ~/.<name>
link_symlink_files () {
  local src dst
  for src in "$DOTFILES_ROOT"/*/*.symlink
  do
    [ -e "$src" ] || continue
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst" || FAILED_COUNT=$((FAILED_COUNT + 1))
  done
}

# topic/links: one "source -> destination" per line. Source is relative to the
# topic folder, destination is relative to $HOME. Blank lines and lines
# starting with # are ignored. Paths may contain spaces.
link_links_files () {
  local manifest topic line src dst
  for manifest in "$DOTFILES_ROOT"/*/links
  do
    [ -f "$manifest" ] || continue
    topic="$(dirname "$manifest")"
    # read the manifest on fd 3 so link_file's prompt still reads the terminal
    while IFS= read -r line <&3 || [ -n "$line" ]
    do
      case "$line" in ''|'#'*) continue ;; esac
      case "$line" in
        *' -> '*) ;;
        *) warn "$(tildify "$manifest"): can't parse line: $line"; continue ;;
      esac
      src="$(trim "${line%% -> *}")"
      dst="$(trim "${line#* -> }")"
      case "$dst" in
        ''|.|./|/*|..|../*|*/..|*/../*)
          warn "$(tildify "$manifest"): destination must be a path under ~ (got '$dst'); skipping"
          continue ;;
      esac
      case "$src" in
        ''|/*|..|../*|*/..|*/../*)
          warn "$(tildify "$manifest"): source must be a path inside the topic folder (got '$src'); skipping"
          continue ;;
      esac
      link_file "$topic/$src" "$HOME/$dst" || FAILED_COUNT=$((FAILED_COUNT + 1))
    done 3< "$manifest"
  done
}

# Remove symlinks that point into the dotfiles repo but whose target no longer
# exists (e.g. after deleting or renaming a file in the repo). Never touches
# links that point anywhere else.
prune_links () {
  local link target
  {
    find "$HOME" -maxdepth 1 -type l
    find "$HOME/.config" "$HOME/.vim" -maxdepth 3 -type l 2>/dev/null
    find "$HOME/Library/Application Support/Code/User" -maxdepth 1 -type l 2>/dev/null
  } | while IFS= read -r link
  do
    target="$(readlink "$link")"
    case "$target" in
      "$DOTFILES_ROOT"/*|"$HOME/.dotfiles"/*) ;;
      *) continue ;;
    esac
    [ -e "$link" ] && continue
    if [ "$DRY_RUN" = "true" ]
    then
      info "would remove dangling $(tildify "$link") -> $(tildify "$target")"
    else
      rm "$link"
      success "removed dangling $(tildify "$link") -> $(tildify "$target")"
    fi
  done
}

link_all () {
  reset_link_answers
  link_symlink_files
  link_links_files
  prune_links
  if [ "$FAILED_COUNT" -gt 0 ]
  then
    warn "links: $OK_COUNT already in place, $LINKED_COUNT new, $FAILED_COUNT failed"
    return 1
  fi
  if [ "$DRY_RUN" != "true" ]
  then
    success "links: $OK_COUNT already in place, $LINKED_COUNT new"
  fi
}
