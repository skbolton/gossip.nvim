## Why

Users frequently want to send their visual selection to a pane (e.g., sending code to an LLM agent). Currently there's no easy way to grab the visual selection and pass it to the chat API—users have to manually handle ranges with `vim.fn.getpos()` and `opts.line1`/`opts.line2`, which is clunky and error-prone.

## What Changes

- Add `gossip.selection()` function that returns the current visual selection as a table of lines
- Returns empty table `{}` if not in visual mode
- Always returns line-wise selection (not character or block-wise)
- Works with any visual mode type (v, V, Ctrl-v)

## Capabilities

### New Capabilities

- `selection-helper`: A utility function to grab the current visual selection as a table of lines, enabling easy composition with the chat API

### Modified Capabilities

(none)

## Impact

- Add `selection()` function to the gossip module in `lua/gossip/init.lua`
- Minimal API surface, very low risk
- No breaking changes to existing API
