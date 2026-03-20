## Context

The gossip plugin has a `send_keys` function that sends raw key sequences to a tmux pane. Currently it only accepts a single string, which limits its usability for complex key sequences.

## Goals / Non-Goals

**Goals:**
- Allow send_keys to accept either a string or table of strings
- Send all keys in a single tmux call (not multiple calls)
- Maintain backward compatibility with existing string usage

**Non-Goals:**
- Changes to chat() API (already accepts tables)
- Additional validation or error handling beyond type checking

## Decisions

**Decision: Accept both string and table in send_keys**
- *Rationale*: Matches the pattern used by chat(), making the API consistent
- *Alternative*: Only accept table (rejected - breaks existing code)

**Decision: Send all keys in one tmux call**
- *Rationale*: More efficient than multiple calls, avoids race conditions
- *Alternative*: Loop through keys with multiple send_keys calls (rejected - less efficient)

**Decision: Use type() to detect string vs table**
- *Rationale*: Simple and reliable Lua pattern
- *Alternative*: Duck typing (overkill for this case)

## Risks / Trade-offs

**Risk**: User passes non-string/table
- *Mitigation*: Simple type check, will error on unexpected types

**Risk**: Empty table passed
- *Mitigation*: No keys sent, no error (matches table.concat behavior)