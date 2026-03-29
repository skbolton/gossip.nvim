## Why

The gossip client currently lacks a way to focus on a specific contact's pane and zoom it for focused interaction. Users need a streamlined way to switch to a contact's pane while simultaneously expanding it to full-screen view, enabling distraction-free communication.

## What Changes

- Add a new `zoom` command that combines pane selection and zooming into a single action
- The command uses `tmux choose-client -t $PANE_ID -z` to both switch focus and zoom the target pane
- Provides intuitive user experience by consolidating two operations into one command

## Capabilities

### New Capabilities
- `zoom`: A new command capability that enables users to focus on and zoom into a contact's tmux pane for full-focus interaction

### Modified Capabilities
- None

## Impact

- New command implementation in the gossip command system
- Integration with tmux for pane manipulation
- May require updates to command registration and help documentation