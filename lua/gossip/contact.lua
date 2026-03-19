local tmux = require("gossip.tmux")
local state = require("gossip.state")

local Contact = {}
Contact.__index = Contact

local config_defaults = {
  breakup_on_exit = false,
  match_command = nil,
}

local function validate_create(create)
  if type(create) == "string" then
    if #create == 0 then
      error("config.create must be a non-empty string")
    end
  elseif type(create) == "table" then
    local keys = {}
    for k, _ in pairs(create) do
      table.insert(keys, k)
    end

    if #keys ~= 1 then
      error("config.create must have exactly one key (split, window), got: " .. table.concat(keys, ", "))
    end

    local key = keys[1]
    if key == "split" then
      local s = create.split
      if type(s) ~= "table" then
        error("config.create.split must be a table")
      end
      if s.dir and not s.dir:match("^[vh]$") then
        error("config.create.split.dir must be 'v' or 'h'")
      end
      if s.size and type(s.size) ~= "string" then
        error("config.create.split.size must be a string")
      end
      if s.command ~= nil and type(s.command) ~= "string" then
        error("config.create.split.command must be a string or nil")
      end
    elseif key == "window" then
      local w = create.window
      if type(w) ~= "table" then
        error("config.create.window must be a table")
      end
      if w.name ~= nil and type(w.name) ~= "string" then
        error("config.create.window.name must be a string or nil")
      end
      if w.command ~= nil and type(w.command) ~= "string" then
        error("config.create.window.command must be a string or nil")
      end
    else
      error("config.create must have key 'split' or 'window', got: " .. key)
    end
  else
    error("config.create must be a string or table")
  end
end

function Contact.validate_config(config)
  if type(config) ~= "table" then
    error("config must be a table, got " .. type(config))
  end

  if type(config.name) ~= "string" or #config.name == 0 then
    error("config.name must be a non-empty string")
  end

  validate_create(config.create)
end

function Contact.new(config)
  Contact.validate_config(config)

  local self = setmetatable({}, Contact)
  self.name = config.name
  self.create = config.create
  self.pane_id = nil
  self.match_command = config.match_command
  self.breakup_on_exit = config_defaults.breakup_on_exit

  if config.breakup_on_exit ~= nil then
    self.breakup_on_exit = config.breakup_on_exit
  end

  return self
end

local function is_pane_valid(pane_id)
  local ok, _err = tmux.execute_tmux_command("list-panes", pane_id)
  if not ok then
    return false
  end
  return true
end

local function find_or_create_pane(contact)
  local pane_id = nil

  if contact.match_command then
    pane_id = tmux.find_pane_by_command(contact.match_command)
    if pane_id then
      return pane_id, false
    end
  end

  local before_ids = tmux.get_pane_ids()
  if not before_ids then
    error("Failed to get pane IDs before creation")
  end

  local _, err = tmux.execute_create_command(contact.create)
  if err then
    error("Failed to create pane: " .. err)
  end

  pane_id, err = tmux.find_new_pane_id(before_ids)
  if not pane_id then
    error("Failed to find new pane ID: " .. err)
  end

  return pane_id, true
end

function Contact.ensure_pane_bound(contact)
  if contact.pane_id and not is_pane_valid(contact.pane_id) then
    contact.pane_id = nil
  end

  if contact.pane_id then
    return contact.pane_id, false
  end

  local pane_id, was_created = find_or_create_pane(contact)
  contact.pane_id = pane_id
  return pane_id, was_created
end

function Contact.get(contact)
  if type(contact) == "string" then
    local c = state.get_contact(contact)
    if not c then
      error("Contact not found: " .. contact)
    end
    return c
  elseif type(contact) == "table" then
    return contact
  else
    error("contact must be a string or table")
  end
end

function Contact.chat(contact, text, opts)
  local c = Contact.get(contact)
  local pane_id, was_created = Contact.ensure_pane_bound(c)

  local submit_key = "Enter"
  if opts and opts.submit then
    submit_key = opts.submit
  end

  local send = function()
    local items = type(text) == "table" and text or { text }
    for _, item in ipairs(items) do
      local ok, err = tmux.send_text(pane_id, item)
      if not ok then
        error("Failed to send text: " .. err)
      end
    end

    local ok, err = tmux.send_keys(pane_id, submit_key)
    if not ok then
      error("Failed to send submit key: " .. err)
    end

    state.set_last_contact(c)
  end

  if was_created then
    vim.defer_fn(send, 150)
  else
    send()
  end
end

function Contact.send_keys(contact, keys)
  local c = Contact.get(contact)
  local pane_id, was_created = Contact.ensure_pane_bound(c)

  local send = function()
    local ok, err = tmux.send_keys(pane_id, keys)
    if not ok then
      error("Failed to send keys: " .. err)
    end
    state.set_last_contact(c)
  end

  if was_created then
    vim.defer_fn(send, 150)
  else
    send()
  end
end

function Contact.clear(contact)
  local c = Contact.get(contact)
  if not c.pane_id then
    return
  end

  local ok, err = tmux.clear_history(c.pane_id)
  if not ok then
    error("Failed to clear history: " .. err)
  end
end

function Contact.breakup(contact)
  local c = Contact.get(contact)
  if c.pane_id then
    local ok, err = tmux.kill_pane(c.pane_id)
    if ok then
      c.pane_id = nil
    else
      if not err:find("no such pane") then
        error("Failed to kill pane: " .. err)
      end
      c.pane_id = nil
    end
  end
end

return Contact
