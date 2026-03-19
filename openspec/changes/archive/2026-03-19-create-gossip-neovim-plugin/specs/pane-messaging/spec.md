## ADDED Requirements

### Requirement: Send Text to Contact
The system SHALL send text to a contact's bound pane.

#### Scenario: Send text creates new pane
- **WHEN** user calls `gossip.chat("test", "hello")`
- **AND** the contact has no bound pane
- **AND** the contact has create config for a split
- **THEN** a new tmux split is created
- **AND** the text "hello" is sent to the new pane
- **AND** an Enter key is sent after the text
- **AND** the contact is bound to the new pane ID

#### Scenario: Send text to existing pane
- **WHEN** user calls `gossip.chat("test", "hello")`
- **AND** the contact is already bound to a valid pane
- **THEN** the text "hello" is sent to the existing pane
- **AND** an Enter key is sent after the text

#### Scenario: Send text with custom submit key
- **WHEN** user calls `gossip.chat("test", "hello", { submit = "C-y" })`
- **AND** the contact has a valid pane
- **THEN** the text "hello" is sent
- **AND** "C-y" (Ctrl+Y) is sent instead of Enter

### Requirement: Send Keys to Contact
The system SHALL send raw key sequences to a contact's bound pane without adding Enter.

#### Scenario: Send control character
- **WHEN** user calls `gossip.send_keys("test", "C-c")`
- **AND** the contact has a valid pane
- **THEN** Ctrl+C is sent to the pane
- **AND** no Enter key is sent

#### Scenario: Send multiple keys
- **WHEN** user calls `gossip.send_keys("test", "C-u")`
- **AND** the contact has a valid pane
- **THEN** Ctrl+U is sent to clear the current line

### Requirement: Pane Auto-resurrection
The system SHALL automatically recreate a contact's pane if it becomes invalid.

#### Scenario: Dead pane is resurrected
- **WHEN** user has a contact bound to a pane
- **AND** that pane no longer exists in tmux
- **AND** user calls `gossip.chat("test", "hello")`
- **THEN** a new pane is created using the contact's create config
- **AND** the new pane ID is stored in the contact
- **AND** the text is sent to the new pane

### Requirement: Get Last Contact
The system SHALL track the most recently messaged contact.

#### Scenario: Last contact is updated on send
- **WHEN** user calls `gossip.chat("ai", "hello")`
- **AND** the message is successfully sent
- **THEN** calling `gossip.get_last_contact()` returns the "ai" contact

#### Scenario: Last contact persists across calls
- **WHEN** user sends to contact "runner"
- **AND** user sends to contact "ai"
- **THEN** calling `gossip.get_last_contact()` returns the "ai" contact