# opencode's installer puts its binary here
if [[ -d $HOME/.opencode/bin ]]
then
  path=("$HOME/.opencode/bin" $path)
fi
