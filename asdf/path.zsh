# asdf shims go in front of Homebrew so asdf-managed node/python/etc. win
path=("${ASDF_DATA_DIR:-$HOME/.asdf}/shims" $path)

# use git clone if present; otherwise falls back to Homebrew
if [[ -f "$HOME/.asdf/asdf.sh" ]]
then
  . "$HOME/.asdf/asdf.sh"
fi

