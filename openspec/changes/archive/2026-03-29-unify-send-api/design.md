## Context

The current `lua/gossip/contact.lua` exposes two functions for sending input to tmux panes:
- `Contact.chat(contact, text, opts)` - sends text then Enter key
- `Contact.send_keys(contact, keys)` - sends keys directly without automatic Enter

Both wrap the underlying `tmux.send_keys()` function. The distinction is confusing and requires users to understand when to use which.

## Goals / Non-Goals

**Goals:**
- Provide a single, explicit API for sending keys to tmux panes
- Remove magic behavior (auto-Enter)
- Expose the new function at both Contact and module level

**Non-Goals:**
- Add new capabilities (this is purely a simplification)
- Handle pane creation logic (already handled by Contact layer)
- Add validation beyond basic parameter checking

## Decisions

### 1. Function name: `send` over `keys` or `type`

**Decision:** Use `Contact.send()` as the unified function name.

**Rationale:** 
- "send" is concise and aligns with tmux's `send-keys` command
- "type" implies character-by-character which isn't accurate
- "keys" is ambiguous (could mean keyboard keys vs. dictionary keys)

### 2. Parameter signature: `send(contact, keys)`

**Decision:** Two parameters - contact identifier and keys (string or table).

```lua
Contact.send("bob", "hello")
Contact.send("bob", {"C-c", "Enter"})
Contact.send("bob", {"hello", "Enter", "more text"})
```

**Rationale:**
- Single parameter for keys allows both string and table
- Table form lets callers specify exact sequence
- No third `opts` parameter - keep it simple for now

### 3. No automatic Enter key

**Decision:** Never automatically append Enter. Callers must pass it explicitly if desired.

**Rationale:**
- Explicit is better than implicit
- Reduces confusion about when Enter is/isn't sent
- Aligns with tmux's mental model (you send exactly what you specify)

### 4. Expose at both Contact and module level

**Decision:** Both `Contact.send()` and `gossip.send()` point to the same implementation.

**Rationale:**
- Maintains consistency with existing pattern
- Users can use whichever fits their usage context

### 5. Handle pane creation delay

**Decision:** Preserve existing `ensure_pane_bound()` delay logic (150ms defer for newly created panes).

**Rationale:**
- Works correctly now, no reason to change
- Ensures pane exists before sending keys

## Risks / Trade-offs

- **[Risk]** Users migrating from chat() may forget to pass Enter
  - **Mitigation:** Clear documentation. The behavior change is explicit and intentional.

- **[Risk]** This is a breaking change for any existing callers
  - **Mitigation:** Project hasn't been released; no external users yet.

- **[Risk]** No validation on keys parameter
  - **Mitigation:** Not needed - tmux will error if invalid keys are passed. Keep it simple.

## Open Questions

- Should we add a shorthand alias like `Contact()` or `Contact.call()`? (No, not in scope)
- Should we add validation for empty strings? (Not needed - tmux handles it)