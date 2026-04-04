## Why

When `gossip.interrupt()` is called on a contact that has no active pane, the current implementation incorrectly creates a new pane via `ensure_pane_bound()`. This violates the expected behavior where interrupt should only send C-c to an existing, running process. Additionally, this causes timing issues when combined with immediate `send()` calls - the shell hasn't finished initializing before commands are sent, leading to broken shell prompts.

## What Changes

- Modify `Contact.interrupt()` to skip pane creation - only operate on existing panes
- Return success (no-op) if the contact has no associated pane - idempotent behavior
- Consider adding a configurable delay for commands sent to newly created panes to allow shell initialization

## Capabilities

### New Capabilities
- None

### Modified Capabilities
- `interrupt-signal`: Update requirement to explicitly state that interrupt MUST NOT create a pane if one doesn't exist, and MUST return success without sending keys (idempotent) when the contact has no pane

## Impact

- Code change in `lua/gossip/contact.lua` - the `Contact.interrupt()` function
- The existing spec at `openspec/specs/interrupt-signal/spec.md` will need a delta spec to document the changed requirement