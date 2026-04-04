## Context

Currently, `Contact.interrupt()` in `lua/gossip/contact.lua` calls `Contact.ensure_pane_bound()` which will create a new pane if one doesn't exist. This is problematic because:

1. **Interrupt semantics**: Calling `interrupt` should send C-c to an *existing* process, not spawn a new one
2. **User confusion**: When users call `gossip.interrupt("tests")` expecting to stop a running test, they instead get a new pane
3. **Timing issues**: Combined with immediate `send()` calls, this causes shell initialization problems

The existing spec at `openspec/specs/interrupt-signal/spec.md` already defines this behavior - interrupt should error when the contact is "not connected".

## Goals / Non-Goals

**Goals:**
- Modify `Contact.interrupt()` to NOT create a pane when none exists
- Return success without sending any keys when contact has no pane (idempotent)
- Align implementation with the existing interrupt-signal specification

**Non-Goals:**
- Adding automatic pane creation logic to interrupt (this is explicitly NOT desired)
- Modifying `send()` behavior (separate concern, though timing may be addressed later)
- Adding new interrupt mechanisms beyond C-c

## Decisions

### Decision: Skip pane creation in interrupt
**Option 1:** Modify `Contact.interrupt()` to check for existing pane and return error if none exists

**Option 2 (Chosen):** Make interrupt a no-op when no pane exists - return success without sending keys
- Chosen: Idempotent behavior is cleaner - calling interrupt on nothing is a no-op

**Option 3:** Add a `create_if_missing` parameter to interrupt
- Rejected: This defeats the purpose - interrupt should never auto-create

### Implementation approach
Modify `Contact.interrupt()` in `lua/gossip/contact.lua` to:
1. Call `Contact.get(contact)` to resolve the contact object
2. Check if `contact.pane_id` is nil
3. If nil, return success immediately (no-op, idempotent)
4. If pane exists, proceed with sending C-c

This mirrors the existing pattern used in `Contact.zoom()` which already validates pane existence before operating.

## Risks / Trade-offs

- **Risk**: Existing users who rely on interrupt creating panes may break
  - **Mitigation**: This is incorrect usage - interrupt should never have created panes. The fix aligns with documented behavior.

- **Risk**: Users may not know a pane doesn't exist
  - **Mitigation**: Idempotent behavior means no error - calling interrupt on nothing is safe

- **Trade-off**: Simple fix vs. more sophisticated detection
  - We could check if the contact's `match_command` pattern finds a running process, but that's scope creep - users should explicitly send to contacts they want to interrupt
