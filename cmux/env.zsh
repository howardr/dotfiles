# Inside cmux, the cmux OpenCode plugins handle alerts. Point opencode-notifier
# at a silent config so each event only alerts once. Outside cmux (Ghostty,
# VS Code) the notifier keeps its default config.
if [[ -n "$CMUX_WORKSPACE_ID" ]]; then
  export OPENCODE_NOTIFIER_CONFIG_PATH="$HOME/.config/opencode/opencode-notifier.cmux.json"
fi

# Inside cmux, stop OpenCode's background `claude` (started by the
# @samiralibabic/opencode-claude provider) from reporting to cmux. Otherwise
# the pane gets two "done" messages per turn: the Claude one with the reply
# text, then ~30s later cmux's OpenCode plugin replaces it with a generic
# "Task completed". With this set, only the OpenCode plugin reports.
# Plain `claude` in other cmux tabs keeps its hooks.
#
# RECHECK LATER (set 2026-11-09, cmux 0.65.2, opencode-claude 0.15.1):
# remove this once cmux's OpenCode plugin sends the reply text instead of
# "Task completed". Test: remove it, run `opencode`, finish a turn, then look at
# ~/Library/Application Support/cmux/notification-feed-history-com.cmuxterm.app.json
if [[ -n "$CMUX_WORKSPACE_ID" ]]; then
  opencode() { CMUX_CLAUDE_HOOKS_DISABLED=1 command opencode "$@"; }
fi
