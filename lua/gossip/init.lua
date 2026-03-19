--- Multi-Gossip Tmux Plugin
-- A NeoVim plugin for managing multiple tmux pane contacts for quick messaging and command execution.
-- @module gossip
-- @see gossip.api
-- @see gossip.contact
-- @see gossip.state
-- @see gossip.tmux

-- ## Error Handling
--
-- All functions throw Lua errors on failure with descriptive messages:
-- - Contact not found: `"Contact not found: <name>"`
-- - Invalid contact: `"contact must be a string or table"`
-- - Tmux command failure: `"Failed to <action>: <error message>"`
-- - Pane capture failure: `"Failed to capture pane ID: <error>"`
--
-- Use `pcall()` to catch errors gracefully:
-- @usage
-- local ok, err = pcall(function()
--   Gossip.chat("mycontact", "hello")
-- end)
-- if not ok then
--   vim.notify("Failed: " .. err, vim.log.LEVEL.ERROR)
-- end
--
-- ## Contact Configuration
--
-- A contact configuration table accepts these fields:
-- @table config
-- @field name string The unique name identifier for this contact (required)
-- @field create string Shell command to create a new tmux pane (required)
-- @field match_command string Pattern to match pane_current_command (if provided, enables pane finding)
-- @field breakup_on_exit boolean Destroy the pane when neovim exits (default: false)
--
-- ## Examples
--
-- Create a contact that splits the window horizontally:
-- @usage
-- local server = Gossip.contact({
--   name = "server",
--   create = "tmux split-window -h"
-- })
-- server:send_command("htop")
--
-- Create a contact that finds an existing pane running bash:
-- @usage
-- local bashpanes = Gossip.contact({
--   name = "bashpanes",
--   create = "tmux split-window -v",
--   match_command = "bash"
-- })
-- bashpanes:chat("echo hello")

local contact_module = require("gossip.contact")
local state = require("gossip.state")

local M = {}

--- Sends text to a contact's pane.
-- @param contact string|table Contact name, contact table, or contact object
-- @param text string|table Text or list of texts to send (e.g. {"text", "C-y"})
-- @return boolean true on success
-- @raise Tmux errors if send fails
-- @usage Gossip.chat("mycontact", "hello world")
-- @usage Gossip.chat("mycontact", {"hello", "C-y"})
-- @usage mycontact:chat("hello world")
function M.chat(contact, text)
  return api.chat(contact, text)
end

--- Sends a command (with Enter) to a contact's pane.
-- @param contact string|table Contact name, contact table, or contact object
-- @param cmd string|table Command or list of commands to execute
-- @return boolean true on success
-- @raise Tmux errors if send fails
-- @usage Gossip.send_command("server", "ls -la")
-- @usage Gossip.send_command("server", {"echo hello", "C-c"})
-- @usage server:send_command("ls -la")
function M.send_command(contact, cmd)
  return api.send_command(contact, cmd)
end

--- Clears the scrollback history of a contact's pane.
-- @param contact string|table Contact name, contact table, or contact object
-- @return boolean true on success
-- @raise Tmux errors if clear fails
-- @usage Gossip.clear_contact("mycontact")
-- @usage mycontact:clear()
function M.clear_contact(contact)
  return api.clear_contact(contact)
end

--- Destroys a contact's pane and removes it from registry.
-- @param contact string|table Contact name, contact table, or contact object
-- @return boolean true on success
-- @raise Tmux errors if pane cannot be killed (and is not already dead)
-- @usage Gossip.breakup("tempcontact")
-- @usage tempcontact:breakup()
function M.breakup(contact)
  return api.breakup(contact)
end

--- Creates or updates a contact configuration.
-- @param config table Contact configuration with name and create fields
-- @return table The created contact table
-- @raise Validation errors for missing/invalid fields
-- @usage Gossip.contact({ name = "dev", create = "tmux split-window -h" })
-- @see gossip.contact.create_contact
function M.contact(config)
  local contact = contact_module.create_contact(config)
  state.register_contact(contact)
  return contact
end

--- Gets a registered contact by name.
-- @param name string The contact name
-- @return table|nil The contact table or nil if not found
-- @usage local c = Gossip.get("mycontact")
function M.get(name)
  return state.get_contact(name)
end

--- Executes an arbitrary tmux command on a contact's pane.
-- @param contact string|table Contact name, contact table, or contact object
-- @param tmux_cmd string tmux command (e.g., "send-keys", "send-keys Enter")
-- @return boolean true on success
-- @raise Tmux errors if command fails
-- @usage Gossip.run_command("mycontact", "send-keys C-c")
-- @usage mycontact:run_command("send-keys C-c")
function M.run_command(contact, tmux_cmd)
  return api.run_command(contact, tmux_cmd)
end

--- Gets the last contacted pane.
-- @return table|nil The last contact table or nil
-- @usage local last = Gossip.get_last_contact()
function M.get_last_contact()
  return state.get_last_contact()
end

--- Sets the last contacted pane.
-- @param contact table The contact to set as last
-- @raise Error if contact is nil
-- @usage Gossip.set_last_contact(mycontact)
function M.set_last_contact(contact)
  state.set_last_contact(contact)
end

return M
