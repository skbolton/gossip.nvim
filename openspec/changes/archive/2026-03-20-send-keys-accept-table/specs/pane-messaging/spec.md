## MODIFIED Requirements

### Requirement: Send Keys to Contact
The system SHALL send raw key sequences to a contact's bound pane without adding Enter. Keys MAY be provided as a single string or as a table of strings. When provided as a table, each key SHALL be sent in sequence.

#### Scenario: Send single key as string
- **WHEN** user calls `gossip.send_keys("test", "C-c")`
- **AND** the contact has a valid pane
- **THEN** Ctrl+C is sent to the pane
- **AND** no Enter key is sent

#### Scenario: Send multiple keys as table
- **WHEN** user calls `gossip.send_keys("test", { "hello", "Enter", "C-y" })`
- **AND** the contact has a valid pane
- **THEN** "hello" is sent to the pane
- **AND** "Enter" is sent to the pane
- **AND** "C-y" is sent to the pane
- **AND** all keys are sent in a single tmux call

#### Scenario: Send control character as table element
- **WHEN** user calls `gossip.send_keys("test", { "C-u" })`
- **AND** the contact has a valid pane
- **THEN** Ctrl+U is sent to clear the current line