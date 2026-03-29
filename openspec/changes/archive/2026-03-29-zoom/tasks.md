## 1. Add Zoom Function to Contact Module

- [x] 1.1 Add `Contact.zoom(contact)` function to lua/gossip/contact.lua
- [x] 1.2 Retrieve pane_id from contact state
- [x] 1.3 Validate pane exists using tmux list-panes
- [x] 1.4 Execute tmux choose-client -t $PANE_ID -z command
- [x] 1.5 Handle error for non-existent contact
- [x] 1.6 Handle error for stale pane ID

## 2. Export Zoom Function in Main Module

- [x] 2.1 Add `M.zoom(contact)` function to lua/gossip/init.lua
- [x] 2.2 Call Contact.zoom() from the export
- [x] 2.3 Add documentation comments