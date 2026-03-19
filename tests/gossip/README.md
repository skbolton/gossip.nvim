# Gossip Plugin Tests

## Running Tests

From within Neovim:

```lua
:luafile tests/gossip/test_init.lua
```

Or run individual test files:

```lua
:luafile tests/gossip/test_contact.lua
:luafile tests/gossip/test_state.lua
:luafile tests/gossip/test_tmux.lua
:luafile tests/gossip/test_api.lua
```

## Test Framework

The tests use a custom lightweight framework defined in `test_lib.lua`:

- `test.describe(name, fn)` - Group related tests
- `test.it(name, fn)` - Individual test case
- `test.assert.are.same(expected, actual)` - Assert equality
- `test.assert.has_error(fn, msg)` - Assert function throws
- `test.assert.has_no_error(fn)` - Assert function succeeds

## Test Files

| File | Tests |
|------|-------|
| `test_contact.lua` | Config validation and contact creation |
| `test_state.lua` | Registry operations and last contact tracking |
| `test_tmux.lua` | Tmux wrapper functions with mocked vim.system |
| `test_api.lua` | API helper functions |
