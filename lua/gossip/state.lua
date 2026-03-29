local M = {}

local contacts = {}
local last_contact = nil

function M.register_contact(contact)
  contacts[contact.name] = contact
end

function M.get_contact(name)
  return contacts[name]
end

function M.get_all_contacts()
  return contacts
end

function M.set_last_contact(contact)
  last_contact = contact
end

function M.get_last_contact()
  return last_contact
end

return M
