# Shared Homebrew packages. Installed by script/bootstrap and `dot --brew`
# (brew bundle install --no-upgrade; `dot --upgrade` upgrades too). Work-only tools stay out of here; see
# TODO.markdown (Brewfile.local).
#
# Apps that were installed by hand (dragged into /Applications) get adopted by
# Homebrew the first time `dot --brew` runs.

# shell
brew "zsh"
brew "coreutils"          # gls, used by system/aliases.zsh
brew "asdf"               # language runtimes, see asdf/tool-versions.symlink

# containers (Colima is the Docker runtime)
brew "colima"
brew "docker"
brew "docker-buildx"
brew "docker-completion"
brew "docker-compose"

# git
brew "glab"

# apps
cask "ghostty"
cask "cmux"
cask "visual-studio-code"
cask "gcloud-cli"
