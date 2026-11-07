# Inside cmux, the cmux OpenCode plugins handle alerts. Point opencode-notifier
# at a silent config so each event only alerts once. Outside cmux (Ghostty,
# VS Code) the notifier keeps its default config.
if [[ -n "$CMUX_WORKSPACE_ID" ]]; then
  export OPENCODE_NOTIFIER_CONFIG_PATH="$HOME/.config/opencode/opencode-notifier.cmux.json"
fi
