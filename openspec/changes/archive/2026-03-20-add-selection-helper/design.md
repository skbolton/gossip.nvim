## Context

The gossip plugin allows users to send text to tmux panes via the chat() API. Users frequently want to send visual selections (selected code, text, etc.) to panes, particularly when talking to LLM agents. Currently there's no built-in way to grab the visual selection—a user must manually handle vim marks and buffer APIs.

## Goals / Non-Goals

**Goals:**
- Add `gossip.selection()` function that returns visual selection as a table of lines
- Simple, minimal API that users can compose with chat()
- Works with all visual mode types (v, V, Ctrl-v)

**Non-Goals:**
- Character-wise or block-wise specific handling (always returns line-wise)
- LSP-aware text objects (paragraph, function, class) - future work
- Visual mode mappings/keybindings - users can create their own

## Decisions

**Decision: Always return line-wise selection**
- *Rationale*: For LLM prompts, line-wise is the common case. Keeps the API simple.
- *Alternative*: Detect mode and return accordingly (rejected - adds complexity for marginal benefit)

**Decision: Return empty table when not in visual mode**
- *Rationale*: Allows users to safely call selection() without error handling
- *Alternative*: Throw error (rejected - too strict for composition with user commands)

**Decision: Implementation uses vim marks '< and '>**
- *Rationale*: Reliable, well-documented, works across all visual types
- *Alternative*: Use visual selection register (rejected - depends on user having yanked)

## Risks / Trade-offs

**Risk**: User calls selection() from non-visual mode unexpectedly
- *Mitigation*: Returns empty table; users should check mode first if they care

**Risk**: Selection spans multiple buffers
- *Mitigation*: Marks '< and '> always refer to current buffer; this is expected behavior