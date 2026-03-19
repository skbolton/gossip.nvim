## ADDED Requirements

### Requirement: Pane Matching by Command
The system SHALL find existing tmux panes by exact command match.

#### Scenario: Find pane by command
- **WHEN** tmux has a pane running "opencode"
- **AND** user has a contact with `match_command = "opencode"` and no bound pane
- **AND** user calls `gossip.chat("ai", "hello")`
- **THEN** the system searches all tmux panes
- **AND** finds the pane where pane_current_command equals "opencode"
- **AND** binds the contact to that pane ID
- **AND** sends the text to the found pane

#### Scenario: No matching pane creates new
- **WHEN** user has a contact with `match_command = "opencode"` and no bound pane
- **AND** no pane exists running "opencode"
- **AND** user calls `gossip.chat("ai", "hello")`
- **THEN** a new pane is created using the create config
- **AND** the contact is bound to the new pane

### Requirement: Pane Creation from Configuration
The system SHALL create tmux panes/windows according to the contact's create configuration.

#### Scenario: Create vertical split
- **WHEN** user has a contact with `create = { split = { dir = "v" } }`
- **AND** the contact has no matching pane
- **AND** user sends a message to the contact
- **THEN** tmux creates a vertical split (left/right)
- **AND** the contact is bound to the new pane

#### Scenario: Create horizontal split
- **WHEN** user has a contact with `create = { split = { dir = "h" } }`
- **AND** the contact has no matching pane
- **AND** user sends a message to the contact
- **THEN** tmux creates a horizontal split (top/bottom)
- **AND** the contact is bound to the new pane

#### Scenario: Create split with size
- **WHEN** user has a contact with `create = { split = { dir = "h", size = "40" } }`
- **AND** the contact has no matching pane
- **AND** user sends a message to the contact
- **THEN** tmux creates a horizontal split with size 40
- **AND** the contact is bound to the new pane

#### Scenario: Create window
- **WHEN** user has a contact with `create = { window = { name = "test" } }`
- **AND** the contact has no matching pane
- **AND** user sends a message to the contact
- **THEN** tmux creates a new window with the specified name
- **AND** the contact is bound to the new pane

#### Scenario: Create split with command
- **WHEN** user has a contact with `create = { split = { dir = "h", command = "opencode" } }`
- **AND** the contact has no matching pane
- **AND** user sends a message to the contact
- **THEN** tmux creates a horizontal split
- **AND** the command "opencode" is run in the new pane

### Requirement: Manual Breakup (Pane Kill)
The system SHALL allow manually killing a contact's bound pane.

#### Scenario: Kill bound pane
- **WHEN** user has a contact bound to a valid pane
- **AND** user calls `gossip.breakup("test")`
- **THEN** the tmux pane is killed
- **AND** the contact's pane_id is set to nil
- **AND** the contact remains registered in the registry

#### Scenario: Breakup on already dead pane
- **WHEN** user has a contact with pane_id set to a dead pane
- **AND** user calls `gossip.breakup("test")`
- **THEN** no error is thrown
- **AND** the contact's pane_id is set to nil

### Requirement: Exit Cleanup
The system SHALL automatically kill panes for contacts with breakup_on_exit on Neovim exit.

#### Scenario: Exit kills breakup_on_exit contacts
- **WHEN** user has a contact with `breakup_on_exit = true` and a valid pane_id
- **AND** Neovim exits (VimLeave autocmd fires)
- **THEN** the tmux pane is killed
- **AND** the contact's pane_id is set to nil

#### Scenario: Exit skips non-breakup contacts
- **WHEN** user has a contact with `breakup_on_exit = false` (default) and a valid pane_id
- **AND** Neovim exits
- **THEN** the tmux pane is NOT killed
- **AND** the pane remains running

#### Scenario: Exit handles dead panes gracefully
- **WHEN** user has a contact with `breakup_on_exit = true` but the pane is already dead
- **AND** Neovim exits
- **THEN** no error is thrown
- **AND** the cleanup continues to other contacts