--- State management for contact registry and pane persistence.
-- @module gossip.state
-- @local

local M = {}

local contacts = {}
local last_contact = nil

function M.register_contact(contact)
  if M.contact_exists(contact.name) then
    error("Contact already exists: " .. contact.name)
  end
  contacts[contact.name] = contact
end

function M.get_contact(name)
  return contacts[name]
end

function M.get_all_contacts()
  return contacts
end

function M.contact_exists(name)
  return contacts[name] ~= nil
end

function M.set_last_contact(contact)
  if contact == nil then
    error("Cannot set last_contact to nil")
  end
  last_contact = contact
end

function M.get_last_contact()
  return last_contact
end

return M
