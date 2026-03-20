## Why

Users need to send multiple keystrokes to a pane in sequence (e.g., typing text, pressing Enter, then pressing Ctrl-y). Currently send_keys only accepts a single string, which gets sent as one literal keypress. Users must build hacky strings with embedded escape sequences or make multiple calls.

## What Changes

- Modify `gossip.send_keys()` to accept either a string (existing behavior) or a table of strings
- When given a table, send each key in sequence in a single tmux call
- This makes it easy to compose key sequences without manual string building

## Capabilities

### New Capabilities

(none - this is an enhancement to existing API)

### Modified Capabilities

- `pane-messaging`: Update send_keys requirement to accept both string and table

## Impact

- Minimal change to lua/gossip/contact.lua and lua/gossip/tmux.lua
- No breaking changes - existing string usage continues to work
- Enables cleaner user code for multi-key sequences