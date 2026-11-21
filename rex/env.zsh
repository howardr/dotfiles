# Inside Rex, Rex shows the tab dot and plays the sound for OpenCode's status,
# but only sends macOS notifications while Rex is in the background, and
# opencode-notifier stays quiet whenever Rex is the front app. This config makes
# the notifier send an OSC 9 notification, which Rex shows as a macOS banner
# even in front, when a session needs permission, asks a question, or fails.
if [[ -n "$REX_SESSION" ]]; then
  export OPENCODE_NOTIFIER_CONFIG_PATH="$HOME/.config/opencode/opencode-notifier.rex.json"
fi
