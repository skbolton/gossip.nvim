## MODIFIED Requirements

### Requirement: Interrupt contact
The system SHALL provide an `interrupt` function that sends a C-c (SIGINT) character to a contact when called. The interrupt function MUST NOT create a new pane if one does not exist for the contact. If no pane exists for the contact, the function MUST return success without sending any keys (idempotent behavior).

#### Scenario: Interrupt a connected contact
- **WHEN** the user calls `interrupt` on a contact that has an active pane
- **THEN** the C-c character is sent to the contact's process
- **AND** the function returns success

#### Scenario: Interrupt a contact with no pane
- **WHEN** the user calls `interrupt` on a contact that has no pane
- **THEN** the function returns success without sending any keys
- **AND** no pane is created
