## Why

Developers often run multiple persistent terminal sessions (REPLs, servers, AI assistants like opencode) alongside Neovim. Existing Neovim plugins for interacting with tmux are focused on single runners targeting a single pane. There is no unified way to treat different terminal panes as persistent "contacts" that can be messaged by name, regardless of where they move in the tmux session.

## What Changes

- **New Neovim plugin "gossip"**: A Lua plugin that registers and manages contacts bound to tmux panes/windows
- **Contact registration API**: `gossip.contact({ name, match_command, create, breakup_on_exit })` allows defining contacts with:
  - `match_command`: Optional command pattern to find existing panes (exact match, first result)
  - `create`: Split or window configuration with direction, size, and command
  - `breakup_on_exit`: Optional flag to kill the pane when Neovim exits
- **Messaging API**: 
  - `gossip.chat(name, text, { submit = "Enter" })`: Send text with optional submit key (default Enter)
  - `gossip.send_keys(name, keys)`: Send raw key sequences
  - `gossip.breakup(name)`: Manually kill a contact's pane
- **Auto-resurrection**: When sending to a contact with a dead pane, automatically recreate using the create config
- **Exit cleanup**: On VimLeave, automatically kill all contacts with `breakup_on_exit` enabled
- **Re-registration support**: Contact names can be redefined without error (supports ftplugin workflows)

## Capabilities

### New Capabilities
- **contact-registration**: Create and register contacts with match/create/cleanup configuration
- **pane-messaging**: Send text and key sequences to bound tmux panes
- **pane-lifecycle**: Handle pane creation, matching, resurrection, and cleanup

### Modified Capabilities
- (none - new plugin)

## Impact

- New Lua plugin in `lua/gossip/` with module structure
- Plugin entry point in `plugin/gossip.lua` with exit autocmd
- Depends on: Neovim (0.10+), tmux
- No external Lua dependencies required