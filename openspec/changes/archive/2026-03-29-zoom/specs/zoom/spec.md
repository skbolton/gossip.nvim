## ADDED Requirements

### Requirement: Zoom command focuses and zooms contact pane
The system SHALL provide a `zoom` command that accepts a contact name and, in a single operation, switches focus to that contact's tmux pane and zooms it to full-screen view.

#### Scenario: Zoom to existing contact
- **WHEN** user executes the zoom command with a valid contact name that exists in gossip state
- **THEN** the system retrieves the pane ID associated with that contact
- **AND** the system executes `tmux choose-client -t $PANE_ID -z` to switch focus and zoom the pane
- **AND** the user's tmux session displays the contact's pane in full-screen mode

#### Scenario: Zoom to non-existent contact
- **WHEN** user executes the zoom command with a contact name that does not exist in gossip state
- **THEN** the system displays an error message indicating the contact was not found
- **AND** no tmux command is executed

#### Scenario: Zoom with valid contact but stale pane ID
- **WHEN** user executes the zoom command with a valid contact name
- **BUT** the pane ID in gossip state no longer exists in tmux
- **THEN** the system displays an error message indicating the pane is no longer available
- **AND** no tmux command is executed