local Contact = require("gossip.contact")
local state = require("gossip.state")

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

function M.chat(contact, text, opts)
  Contact.chat(contact, text, opts)
end

function M.send_keys(contact, keys)
  Contact.send_keys(contact, keys)
end

function M.breakup(contact)
  Contact.breakup(contact)
end

function M.get_last_contact()
  return state.get_last_contact()
end

function M.set_last_contact(contact)
  state.set_last_contact(contact)
end

function M.selection()
  local mode = vim.fn.mode()
  if not mode:find("v") then
    return {}
  end

  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  local start_line = start_pos[2]
  local end_line = end_pos[2]

  local lines = vim.api.nvim_buf_get_text(0, start_line - 1, 0, end_line - 1, 0, {})
  return lines
end

return M
