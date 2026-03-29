# AGENTS.md - Gossip Development Guide

Gossip is a Neovim plugin that allows users to configure "contacts" which represent panes either in the same window as
neovim or in a separate window of the session that they might want to interract with. It provides commands for sending
text to contacts, zooming them, or interrupting them. Users can use this to have general runner contacts or even ai
assistant panes they are sending text to.

**Tech Stack:**
- Language: Lua (Neovim plugin)
- Build: Nix Flakes (flake.nix)
- Formatter: stylua
- Specification: OpenSpec (openspec/)

## Build/Lint/Test Commands

### Code Formatting

Format all Lua files:
```bash
stylua lua/
```

Format a single file:
```bash
stylua lua/gossip/init.lua
```

### Development Environment

Enter the development shell:
```bash
nix develop
# or
direnv allow  # if .envrc is set up
```

This provides:
- stylua (Lua formatter)
- openspec (specification tool)

### OpenSpec Commands

Validate specs:
```bash
openspec validate
```

Create new change:
```bash
openspec change new <name>
```

Continue working on change:
```bash
openspec change continue
```

**Note:** No test suite currently exists. Test commands are not applicable.

## Code Style Guidelines

### General Conventions

- **Indentation**: 2 spaces (no tabs)
- **Line ending**: Unix (LF)
- **Maximum line length**: 120 characters (soft guideline)
- **File encoding**: UTF-8

### Lua Code Style

**Imports:**
```lua
local Module = require('module.path')
```

**Module Pattern:**
```lua
local M = {}

-- Public functions
function M.function_name(args)
  -- implementation
end

return M
```

**Tables as Modules (classes):**
```lua
local Contact = {}
Contact.__index = Contact

function Contact.new(config)
  local self = setmetatable({}, Contact)
  -- initialization
  return self
end

return Contact
```

**Naming Conventions:**
- Variables/functions: `snake_case` (e.g., `contact_name`, `get_contact`)
- Constants: `UPPER_SNAKE_CASE` (e.g., `DEFAULT_TIMEOUT`)
- Module names: `snake_case` (e.g., `gossip.contact`)
- File names: `snake_case.lua` (e.g., `contact.lua`)
- Tables (classes): `PascalCase` (e.g., `Contact`, `TmuxClient`)

**Error Handling:**
```lua
-- Validate inputs early
if type(config) ~= 'table' then
  error('config must be a table, got ' .. type(config))
end

-- Use ok/err pattern for function calls
local ok, err = some_function()
if not ok then
  error('Failed to do something: ' .. err)
end

-- Return nil, error on failure
return nil, 'error message'
```

**Control Flow:**
```lua
-- Prefer early returns
local function process(data)
  if not data then
    return nil, 'no data'
  end
  
  if not data.valid then
    return nil, 'invalid data'
  end
  
  return process_valid(data)
end
```

### Documentation

Use LuaDoc comments for public functions:

```lua
--- Description of what the function does.
-- Extended description if needed.
-- @param contact string|table Contact name or Contact object
-- @param keys string|table Keys to send (single string or table of keys)
-- @return boolean success, string? error
-- @usage
--   gossip.send("bob", "hello")
--   gossip.send("bob", {"hello", "Enter"})
function M.send(contact, keys)
  -- implementation
end
```

### Formatting Details (from stylua.toml)

- **Indent type**: Spaces
- **Indent width**: 2
- **Quote style**: AutoPreferSingle

## Project Structure

```
gossip/
├── lua/gossip/          # Main plugin code
│   ├── init.lua         # Entry point, public API
│   ├── contact.lua      # Contact class and methods
│   ├── tmux.lua         # Tmux interaction layer
│   └── state.lua        # In-memory state management
├── plugin/gossip.lua    # Neovim plugin entry point
├── openspec/
│   ├── specs/           # Feature specifications
│   │   ├── contact-registration/
│   │   ├── pane-lifecycle/
│   │   ├── pane-messaging/
│   │   ├── selection-helper/
│   │   ├── interrupt-signal/
│   │   └── zoom/
│   ├── config.yaml      # OpenSpec configuration
│   └── changes/         # Change artifacts (archive/)
├── stylua.toml          # Code formatter config
├── opencode.json        # opencode agent config
├── flake.nix            # Nix development environment
└── .envrc               # direnv configuration
```

## Key Patterns

**Contact Creation:**
1. Validate config with `Contact.validate_config(config)`
2. Create with `Contact.new(config)`
3. Register with `state.register_contact(contact)`
4. Ensure pane with `Contact.ensure_pane_bound(contact)`

**Sending Keys:**
1. Get contact (string name or table)
2. Ensure pane bound (creates if needed)
3. Send keys via tmux
4. Set as last contact in state

**Error Messages:**
- Start with lowercase: `'failed to ...'`
- Include context: `'Failed to send keys: ' .. err`
- Be descriptive but concise

## OpenSpec Workflow

The project uses OpenSpec for specification-driven development:

1. **New change**: `openspec change new <feature-name>`
2. **Artifacts**: proposal → design → spec → tasks → implementation
3. **Validate**: `openspec validate` to check spec consistency
4. **Archive**: Complete changes get archived in `openspec/changes/archive/`

Spec files are in `openspec/specs/<feature>/spec.md`.

## Configuration Files

- `stylua.toml`: Lua formatting rules
- `opencode.json`: opencode agent configuration
- `flake.nix`: Nix development environment
- `.envrc`: direnv auto-activation
- `openspec/config.yaml`: OpenSpec settings
