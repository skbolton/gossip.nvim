## ADDED Requirements

### Requirement: Interrupt contact
The system SHALL provide an `interrupt` function that sends a C-c (SIGINT) character to a contact when called.

#### Scenario: Interrupt a connected contact
- **WHEN** the user calls `interrupt` on a contact that is connected
- **THEN** the C-c character is sent to the contact's process
- **AND** the function returns success

#### Scenario: Interrupt a disconnected contact
- **WHEN** the user calls `interrupt` on a contact that is not connected
- **THEN** the function returns an error indicating the contact is not connected