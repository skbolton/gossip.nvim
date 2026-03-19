## Context

This is a new Neovim Lua plugin with no existing codebase. The plugin communicates with tmux to manage persistent terminal panes that can be messaged from Neovim.

### Current State
- No existing plugin or equivalent functionality
- Users manually switch to terminal panes to interact with running processes
- Existing plugins (vim-tmux-runner, etc.) focus on single runner patterns

### Constraints
- Requires tmux to be running
- In-memory state only (no persistence across Neovim restarts)
- Must handle tmux being unavailable gracefully

## Goals / Non-Goals

**Goals:**
- Provide contact-based API for managing tmux pane references
- Support both split and window creation with configurable direction/size
- Enable exact command matching to find existing panes
- Auto-resurrect dead panes on message send
- Clean exit hook for contacts with breakup_on_exit

**Non-Goals:**
- Visual UI or integration with statusline/bufferline
- Cross-session tmux management (only current session)
- Persistent state across Neovim restarts
- Support for environments other than tmux

## Decisions

### 1. Module Structure: Separate Files

**Decision**: Split into `init.lua`, `contact.lua`, `tmux.lua`, `state.lua`

**Rationale**: Clear separation of concerns
- `init.lua` - Public API and module exports
- `contact.lua` - Contact creation, validation, instance methods
- `tmux.lua` - Low-level tmux command wrappers
- `state.lua` - In-memory registry of contacts

**Alternative considered**: Single monolithic file → harder to maintain and test

### 2. Pane ID Tracking: Absolute IDs Over Relative Selectors

**Decision**: Store actual tmux pane IDs (e.g., `%10`, `@1`) rather than relative selectors like `{left}`, `{right}`

**Rationale**: Relative selectors break when panes move or windows are rearranged. Absolute IDs remain valid even after:
- Pane swaps within a window
- Pane is broken out into new window
- Window is moved to different position in layout

**Alternative considered**: Use tmux's `{last}` or `{left}` → brittle to movement

### 3. Pane Matching: First Match Only

**Decision**: When multiple panes match the command pattern, return the first match

**Rationale**: Simplicity. Multiple matches would require user disambiguation. First match is predictable and matches the "contact" mental model (one direct line to each entity).

**Alternative considered**: Return all matches, require user to pick → adds complexity without clear benefit for the primary use cases

### 4. Send API: Options Table Over Array

**Decision**: `gossip.chat(name, text, { submit = "Enter" })` instead of `gossip.chat(name, {"text", "C-y"})`

**Rationale**: 
- More readable and self-documenting
- Options are explicit about what they control
- Easier to extend with additional options later

**Alternative considered**: Array syntax → compact but less clear about semantics

### 5. Re-registration: Allow Without Error

**Decision**: Calling `gossip.contact()` with an existing name overwrites the previous registration without error

**Rationale**: Supports ftplugin workflows where the same contact may be defined in multiple places or re-defined on buffer entry. Erroring would require users to check existence first.

**Alternative considered**: Require explicit "update" flag or check-then-register → adds friction for ftplugin use case

### 6. Creation Delay: Hardcoded Wait

**Decision**: Hardcoded 150-250ms delay after pane creation before first send

**Rationale**: Terminal applications need time to initialize. Making this configurable adds complexity for marginal benefit. Can be revisited if users report issues.

**Alternative considered**: Poll for readiness or remove delay → risks sending to unready panes

### 7. API Style: Module Functions Over Instance Methods

**Decision**: All API calls go through `gossip.chat()`, `gossip.send_keys()`, etc. rather than instance methods like `contact:chat()`

**Rationale**: 
- Simpler mental model: one way to call everything
- No need to store reference to contact object
- Works naturally with string names: `gossip.chat("ai", "hello")`
- Easier to document and discover

**Alternative considered**: Instance methods on contact objects → more OOP, but adds indirection

### 8. Setup Function for Future Configuration

**Decision**: Provide `gossip.setup({})` entrypoint even with no initial config options

**Rationale**: 
- Follows Neovim plugin conventions (like many other plugins)
- Provides a clear place to add configuration later (e.g., log levels for debugging)
- Users can call it without errors even if empty
- No config currently, but easily extensible

**Example**:
```lua
-- In init.vim/lua config:
require('gossip').setup({
  log_level = 'info',  -- future option
})
```

### 9. Session Target: Always Current Session

**Decision**: All tmux operations target the session Neovim is running in (not configurable)

**Rationale**: Most users run Neovim within a tmux session. Supporting other sessions adds complexity without clear benefit. The plugin operates in the current tmux context.

### 10. Exit Cleanup: Loop Registry on VimLeave

**Decision**: On VimLeave, iterate all registered contacts and kill those with `breakup_on_exit`

**Rationale**: 
- Simple and predictable
- Only kills contacts that opt-in via config
- Registry provides a single source of truth

**Alternative considered**: Per-contact exit hooks → more complex, harder to manage

## Risks / Trade-offs

- **[Risk]** tmux not running when sending → **[Mitigation]** Log error, return failure to caller
- **[Risk]** Pane dies between match and send → **[Mitigation]** Auto-resurrect: re-run create command, find new pane ID
- **[Risk]** Race on pane creation (tmux slow to create) → **[Mitigation]** Hardcoded delay before first send
- **[Risk]** Exit hook errors → **[Mitigation]** Log errors but continue with remaining contacts
- **[Risk]** Pane ID stale but still exists in different form → **[Mitigation]** Validation check before send, resurrect if invalid
- **[Trade-off]** In-memory only: Contacts lost on Neovim restart → Acceptable for MVP, can add persistence layer later

## Open Questions

(None remaining - all decisions made)