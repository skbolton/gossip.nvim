## ADDED Requirements

### Requirement: Contact Creation with Configuration
The system SHALL allow users to create a contact by providing a name and create configuration.

#### Scenario: Create contact with split configuration
- **WHEN** user calls `gossip.contact({ name = "test", create = { split = { dir = "h" } } })`
- **THEN** a contact named "test" is registered in the gossip registry
- **AND** the contact stores the create configuration for future pane creation

#### Scenario: Create contact with window configuration
- **WHEN** user calls `gossip.contact({ name = "test", create = { window = { name = "mywindow" } } })`
- **THEN** a contact named "test" is registered in the gossip registry
- **AND** the contact stores the window creation config

### Requirement: Contact Registration in State
The system SHALL register created contacts in a central registry for later lookup.

#### Scenario: Contact is retrievable by name
- **WHEN** user registers a contact with name "ai"
- **AND** later calls `gossip.get("ai")`
- **THEN** the contact table is returned
- **AND** the contact has name, create, and pane_id fields

#### Scenario: Get all contacts
- **WHEN** user registers multiple contacts
- **AND** calls `gossip.get_all_contacts()`
- **THEN** all registered contacts are returned as a table

### Requirement: Re-registration Without Error
The system SHALL allow re-registering a contact with the same name without throwing an error.

#### Scenario: Re-registering contact overwrites existing
- **WHEN** user creates a contact with name "ai" and create config A
- **AND** later creates another contact with name "ai" and create config B
- **THEN** the second contact replaces the first
- **AND** calling `gossip.get("ai")` returns the new contact with config B

### Requirement: Match Command Configuration
The system SHALL allow configuring a match_command to find existing panes.

#### Scenario: Contact stores match_command
- **WHEN** user creates a contact with `match_command = "opencode"`
- **AND** the contact is retrieved
- **THEN** the contact has match_command field set to "opencode"

### Requirement: Breakup on Exit Configuration
The system SHALL allow configuring breakup_on_exit to control pane cleanup on Neovim exit.

#### Scenario: Contact stores breakup_on_exit
- **WHEN** user creates a contact with `breakup_on_exit = true`
- **AND** the contact is retrieved
- **THEN** the contact has breakup_on_exit field set to true