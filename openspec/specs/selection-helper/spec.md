# Selection Helper

## Purpose

TBD - Helper utilities for working with visual selections in Neovim.

## Requirements

### Requirement: gossip.selection() returns visual selection as lines
The `gossip.selection()` function SHALL return the current visual selection as a table of strings, where each string is a line of text. If not in visual mode, it SHALL return an empty table.

#### Scenario: Returns selected lines in visual mode
- **WHEN** user selects lines in visual mode (v, V, or Ctrl-v) and calls `gossip.selection()`
- **THEN** function returns a table containing each selected line as a string

#### Scenario: Returns empty table when not in visual mode
- **WHEN** user calls `gossip.selection()` while in normal mode
- **THEN** function returns an empty table `{}`

#### Scenario: Returns line-wise selection
- **WHEN** user makes any type of visual selection and calls `gossip.selection()`
- **THEN** function returns complete lines, not partial characters or blocks