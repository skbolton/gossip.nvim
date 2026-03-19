## 1. Project Setup

- [x] 1.1 Create plugin directory structure (lua/gossip/, plugin/, tests/)
- [x] 1.2 Create plugin entry point at plugin/gossip.lua with exit autocmd

## 2. State Management Module

- [x] 2.1 Create lua/gossip/state.lua with contact registry
- [x] 2.2 Implement register_contact() with overwrite support
- [x] 2.3 Implement get_contact(), get_all_contacts()
- [x] 2.4 Implement set_last_contact() and get_last_contact()

## 3. Tmux Integration Module

- [x] 3.1 Create lua/gossip/tmux.lua with low-level tmux wrappers
- [x] 3.2 Implement execute_tmux_sync() for synchronous command execution
- [x] 3.3 Implement list_panes() to get all panes with commands
- [x] 3.4 Implement find_pane_by_command() for exact match (first result)
- [x] 3.5 Implement get_pane_ids() and find_new_pane_id() for creation detection
- [x] 3.6 Implement send_text() and send_keys() for pane messaging
- [x] 3.7 Implement clear_history() and kill_pane() for lifecycle
- [x] 3.8 Implement build_create_command() for split/window configs

## 4. Contact Module

- [x] 4.1 Create lua/gossip/contact.lua
- [x] 4.2 Implement validate_create() for split/window config validation
- [x] 4.3 Implement Contact.new() constructor with config validation
- [x] 4.4 Implement is_pane_valid() to check pane existence
- [x] 4.5 Implement find_or_create_pane() with match and creation logic
- [x] 4.6 Implement ensure_pane_bound() for resurrection handling

## 5. Main Module (API)

- [x] 5.1 Create lua/gossip/init.lua
- [x] 5.2 Implement gossip.contact() for registration
- [x] 5.3 Implement gossip.chat() with text + optional submit key
- [x] 5.4 Implement gossip.send_keys() for raw key sequences
- [x] 5.5 Implement gossip.breakup() for manual pane kill
- [x] 5.6 Implement gossip.get() and gossip.get_all_contacts()
- [x] 5.7 Implement gossip.get_last_contact() and set_last_contact()
- [x] 5.8 Export module with proper Neovim module pattern

## 6. Exit Hook Integration

- [x] 6.1 Add VimLeave autocmd in plugin/gossip.lua
- [x] 6.2 Iterate contacts and kill those with breakup_on_exit
- [x] 6.3 Handle errors gracefully during exit cleanup

