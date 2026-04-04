## 1. Modify Contact.interrupt() Implementation

- [x] 1.1 Read current `Contact.interrupt()` implementation in `lua/gossip/contact.lua`
- [x] 1.2 Remove `ensure_pane_bound()` call from interrupt function
- [x] 1.3 Add pane existence check before sending C-c
- [x] 1.4 Return success (do nothing) when pane is nil - idempotent behavior
- [x] 1.5 Keep existing C-c sending logic for when pane exists

## 2. Format

- [x] 2.1 Run stylua on modified contact.lua