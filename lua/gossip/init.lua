local Contact = require('gossip.contact')
local state = require('gossip.state')

local M = {}

-- function M.setup(_opts)
-- end

function M.contact(config)
  local contact = Contact.new(config)
  state.register_contact(contact)
  return contact
end

function M.get(name)
  return state.get_contact(name)
end

function M.get_all_contacts()
  return state.get_all_contacts()
end

--- Sends keys to a contact's tmux pane.
-- Each string in the table is passed to tmux's send-keys command as a separate
-- argument, meaning tmux evaluates them individually. For example, {"hello", "Enter"}
-- sends "hello" then presses Enter, whereas "hello Enter" treats the entire string
-- as a single literal that tmux would type literally.
-- @param contact string|table Contact name or Contact object
-- @param keys string|table Keys to send (single string or table of keys)
-- @usage
--   gossip.send("bob", "hello")
--   gossip.send("bob", {"hello", "Enter"})
--   gossip.send("bob", {"hello", "C-y"})  -- Ctrl+Y instead of Enter
function M.send(contact, keys)
  Contact.send(contact, keys)
end

--- Sends C-c (SIGINT) to a contact's tmux pane.
-- This interrupts the process running in the contact's pane.
-- @param contact string|table Contact name or Contact object
-- @usage
--   gossip.interrupt("bob")
function M.interrupt(contact)
  Contact.interrupt(contact)
end

function M.breakup(contact)
  Contact.breakup(contact)
end

--- Zooms and focuses on a contact's tmux pane.
-- This combines pane selection and zooming into a single action,
-- switching focus to the contact's pane while expanding it to full-screen view.
-- @param contact string|table Contact name or Contact object
-- @usage
--   gossip.zoom("bob")
function M.zoom(contact)
  Contact.zoom(contact)
end

function M.get_last_contact()
  return state.get_last_contact()
end

function M.set_last_contact(contact)
  state.set_last_contact(contact)
end

function M.selection()
  local mode = vim.fn.mode()
  if not (mode:find('v') or mode:find('V')) then
    return {}
  end

  vim.cmd("'<,'>yank")
  local selection = vim.fn.getreg('"')
  if not selection or selection == '' then
    return {}
  end

  local lines = {}
  for line in selection:gmatch('[^\r\n]+') do
    table.insert(lines, line)
  end
  return lines
end

return M
