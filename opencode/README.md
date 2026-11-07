# OpenCode config

OpenCode config is split into two files:

| Config       | File                              | Tracked? | Contents                                    |
| ------------ | --------------------------------- | -------- | ------------------------------------------- |
| **Personal** | `opencode.jsonc` (this directory) | Yes      | Permissions, plugins, generic MCP servers   |
| **Work**     | `~/.config/opencode/work.jsonc`   | **No**   | Default model, employer-specific MCP servers |

Anything that references internal hostnames, employer MCP servers, or
work-only providers/models goes in the **work** config. Everything else goes
in the **personal** config.

## How it fits together

```
~/.config/opencode/
├── opencode.jsonc     -> ~/.dotfiles/opencode/opencode.jsonc   (personal, symlink)
├── work.jsonc                                                  (work, untracked)
├── opencode-notifier.cmux.json -> ~/.dotfiles/opencode/...     (symlink)
└── plugins/                                                    (managed by cmux)

~/.localrc                                                      (untracked)
└── export OPENCODE_CONFIG="$HOME/.config/opencode/work.jsonc"
```

- `opencode/links` symlinks the personal config and the notifier config
  into `~/.config/opencode/` (via `script/link`, which `dot` and
  `script/bootstrap` run).
- `zsh/zshrc.symlink` sources `~/.localrc`, which sets `OPENCODE_CONFIG`.
- OpenCode loads `$OPENCODE_CONFIG` **after** the global
  `~/.config/opencode/opencode.jsonc`, so the work config wins when both set
  the same key. Non-conflicting keys (e.g. separate `mcp` entries) merge.

Load order (lowest to highest precedence), as shown by
`opencode debug config --print-logs --log-level DEBUG`:

1. Remote org config, if your employer provides one
2. `~/.config/opencode/opencode.json(c)` - personal
3. `$OPENCODE_CONFIG` - work
4. Project configs (`./opencode.json(c)`, `./.opencode/`)

## Setting up a new work machine

1. Run `script/bootstrap` to symlink the personal config.

2. Create the work config at `~/.config/opencode/work.jsonc`:

   ```jsonc
   // Work OpenCode config. NOT tracked in ~/.dotfiles.
   // Loaded via OPENCODE_CONFIG, set in ~/.localrc.
   {
     "$schema": "https://opencode.ai/config.json",
     "model": "<provider>/<model>",
     "mcp": {
       // Enable a server already defined by a remote org config:
       "<org-server>": { "enabled": true },
       // Or define a new one:
       "<internal-server>": {
         "type": "remote",
         "url": "https://<internal-host>/mcp",
         "oauth": {},
         "enabled": true
       }
     }
   }
   ```

3. Point OpenCode at it from `~/.localrc`:

   ```sh
   # Work OpenCode config (merged on top of personal dotfiles config)
   export OPENCODE_CONFIG="$HOME/.config/opencode/work.jsonc"
   ```

4. Install the cmux plugins (the personal config references
   `./plugins/cmux`):

   ```sh
   cmux hooks setup
   ```

   cmux owns the files in `~/.config/opencode/plugins/` and upgrades them in
   place, so they are not tracked here. It may also create
   `~/.config/opencode/opencode.json`. Delete that file if it only contains
   the `./plugins/cmux` entry, since the personal config already loads it.

On a personal machine, skip steps 2 and 3.

## Verifying

Open a new shell (so `~/.localrc` is sourced), then:

```sh
echo $OPENCODE_CONFIG          # should print the work.jsonc path

# Work + personal: expect the work model and all MCP servers
opencode debug config | jq '{model, mcp: (.mcp | keys), plugin}'

# Personal only: work model and work-only MCP servers should disappear
env -u OPENCODE_CONFIG opencode debug config | jq '{model, mcp: (.mcp | keys)}'
```

Restart any running OpenCode sessions to pick up changes.

## Caveats

- `OPENCODE_CONFIG` is only set in shells that source `~/.localrc`. OpenCode
  launched from a GUI app that did not inherit a login shell environment will
  not load the work config.
- If the same key is set in both files, the work config wins. Keep keys
  disjoint where possible to avoid surprises.
