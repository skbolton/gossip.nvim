## Context

Gossip is a communication tool that manages contacts and allows sending messages/signals to them. Currently, users can send arbitrary data using the `send` API, but there is no dedicated way to send an interrupt signal (C-c / SIGINT). This design outlines how to add a convenience `interrupt` function.

## Goals / Non-Goals

**Goals:**
- Add an `interrupt` function to gossip that sends C-c to a contact
- Make the API more intuitive for a common operation
- Maintain consistency with existing gossip patterns

**Non-Goals:**
- Support for other signal types (SIGTERM, SIGHUP, etc.) - these can be added later
- Complex error handling beyond what the existing `send` API provides
- Changes to the underlying contact architecture

## Decisions

1. **Create a dedicated `interrupt` function** (vs extending the `send` API with flags)
   - Rationale: A dedicated function is more discoverable and semantic. Users looking to interrupt a contact can find `interrupt` directly rather than knowing to pass a special character to `send`.
   - Alternative considered: Add a `signal` parameter to `send` - rejected because it muddies the simple `send` API with edge case functionality

2. **Use existing `send` infrastructure internally**
   - Rationale: Leverage existing contact communication code rather than duplicating logic
   - The `interrupt` function will call `send` with the C-c character

3. **Return the same response type as `send`**
   - Rationale: Consistent API behavior - callers can handle success/failure the same way regardless of what they're sending

## Risks / Trade-offs

- **Low risk**: Simple wrapper around existing functionality
- **No migration needed**: Pure addition, no breaking changes

## Migration Plan

- Deploy as a new function addition
- No migration required - existing code continues to work unchanged
- Rollback: Simply remove the function if issues arise

## Open Questions

- None at this time