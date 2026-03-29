## Context

The gossip client interacts with tmux to manage contact panes. Currently, users must perform two separate operations to focus on a contact's pane: first select the pane, then zoom it. This creates friction in the user experience, especially when frequently switching between contacts.

The tmux `choose-client` command with the `-z` flag provides functionality to both select a client (pane) and zoom it in a single action. This change leverages that capability to create a streamlined workflow.

## Goals / Non-Goals

**Goals:**
- Enable single-command focus and zoom on a contact's tmux pane
- Provide intuitive UX by consolidating pane selection and zooming
- Integrate seamlessly with existing gossip command architecture

**Non-Goals:**
- Modify existing pane selection or zoom commands
- Add tmux session management capabilities
- Implement pane un-zoom functionality (remains separate command)

## Decisions

1. **Command implementation approach**: Create a new top-level `zoom` command rather than extending existing commands
   - Rationale: Maintains clear separation of concerns; zoom behavior is distinct from pane selection
   
2. **Tmux integration**: Use `tmux choose-client -t $PANE_ID -z` for combined selection and zoom
   - Rationale: Single tmux call is more efficient; built-in tmux behavior is well-tested
   - Alternative considered: Separate `select-pane` + `resize-pane` calls (rejected due to extra overhead)

3. **Error handling**: Require valid pane ID; fail gracefully if pane doesn't exist
   - Rationale: Prevents invalid tmux commands; provides clear feedback

## Risks / Trade-offs

- **Risk**: tmux version compatibility with `choose-client -z` flag
  - Mitigation: Verify tmux version requirement; add version check
  
- **Risk**: Pane ID validity at time of command execution
  - Mitigation: Validate pane exists before calling tmux; provide clear error message

- **Trade-off**: Single command is less flexible than separate zoom toggle
  - Rationale: User research indicated preference for focused workflow over toggle capability
