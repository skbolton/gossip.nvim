## Why

The codebase currently exposes two APIs for sending input to tmux panes: `chat()` and `send_keys()`. Both wrap tmux's `send-keys` command but have subtle behavioral differences that create confusion. The `chat()` function automatically appends an Enter key, while `send_keys()` does not. This requires users to understand when to use which API and creates unnecessary cognitive overhead.

## What Changes

- Collapse `Contact.chat()` and `Contact.send_keys()` into a single `Contact.send()` function
- Remove automatic Enter key submission - callers must explicitly pass the keys they want evaluated
- Remove the `opts` parameter from the API entirely
- Expose the new `send()` function at both the Contact level and module level (`gossip.send()`)
- **BREAKING**: Remove the old `chat()` and `send_keys()` functions

## Capabilities

### New Capabilities
- `unified-send-api`: Single API for sending keys to tmux panes with explicit control

### Modified Capabilities
- (none - this is an internal API cleanup with no spec-level behavior change)

## Impact

- **Files modified:**
  - `lua/gossip/contact.lua` - collapse functions
  - `lua/gossip/init.lua` - update exports
- **API surface:** Reduced from 2 functions to 1
- **User-facing:** Simpler mental model - just pass the exact keys you want tmux to evaluate
