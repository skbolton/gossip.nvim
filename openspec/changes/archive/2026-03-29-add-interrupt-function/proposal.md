## Why

Users need a convenient way to interrupt a contact by sending a C-c (SIGINT) signal. While this could be accomplished using the existing `send` API, this is a common enough operation that having a dedicated `interrupt` function would improve usability and make the API more intuitive.

## What Changes

- Add a new `interrupt` function to the gossip module that can be called on a contact
- The function sends the C-c character to the contact's process
- The function provides a cleaner, more semantic API than using raw `send`

## Capabilities

### New Capabilities
- `interrupt-signal`: A new capability to send interrupt signals (C-c) to contacts

### Modified Capabilities
- (none)

## Impact

- New function added to gossip's public API
- Affects contact handling code
- No changes to existing capabilities or their requirements