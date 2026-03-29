## ADDED Requirements

### Requirement: Contact.send() sends keys to tmux pane
The Contact.send() function SHALL send the specified keys to the tmux pane associated with the contact. Keys SHALL be interpreted by tmux according to tmux's send-keys command semantics.

#### Scenario: Send single string
- **WHEN** caller invokes `Contact.send(contact, "hello")`
- **THEN** the string "hello" is sent to the contact's tmux pane without any additional keys

#### Scenario: Send multiple keys as table
- **WHEN** caller invokes `Contact.send(contact, {"C-c", "Enter"})`
- **THEN** the keys "C-c" and "Enter" are sent sequentially to the contact's tmux pane

#### Scenario: Send mixed text and keys
- **WHEN** caller invokes `Contact.send(contact, {"hello", "Enter", "more text"})`
- **THEN** "hello" is sent, then Enter key is sent, then "more text" is sent

#### Scenario: Send to newly created pane
- **WHEN** caller invokes Contact.send() on a contact whose pane was just created
- **THEN** the keys are deferred by 150ms to ensure pane is ready before sending

### Requirement: Module-level gossip.send() exposes Contact.send()
The module-level function gossip.send() SHALL expose the same functionality as Contact.send(), accepting a contact identifier and keys.

#### Scenario: Module-level send
- **WHEN** caller invokes `gossip.send(contact, "text")`
- **THEN** the behavior is identical to calling `Contact.send(contact, "text")`

### Requirement: Old chat() and send_keys() functions are removed
The chat() and send_keys() functions SHALL NOT exist after this change.

#### Scenario: Calling removed chat function
- **WHEN** caller invokes `Contact.chat()` or `gossip.chat()`
- **THEN** an error SHALL be raised indicating the function does not exist

#### Scenario: Calling removed send_keys function
- **WHEN** caller invokes `Contact.send_keys()` or `gossip.send_keys()`
- **THEN** an error SHALL be raised indicating the function does not exist