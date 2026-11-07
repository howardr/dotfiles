# asdf shims go in front of Homebrew so asdf-managed node/python/etc. win
path=("${ASDF_DATA_DIR:-$HOME/.asdf}/shims" $path)
