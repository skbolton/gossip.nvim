--- Gossip contact creation and instance methods.
-- @module gossip.contact
-- @local

local tmux = require("gossip.tmux")
local state = require("gossip.state")

local M = {}

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

local function is_pane_valid(pane_id)
  local ok, _err = tmux.execute_tmux_command("list-panes -t", pane_id)
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

local function ensure_pane_bound(contact)
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

local function get_contact_table(contact)
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

local function send_texts(pane_id, texts)
  local items = type(texts) == "table" and texts or { texts }
  for _, item in ipairs(items) do
    local ok, err = tmux.send_text(pane_id, item)
    if not ok then
      return false, err
    end
  end
  return true, nil
end

function M.validate_config(config)
  if type(config) ~= "table" then
    error("config must be a table, got " .. type(config))
  end

  if type(config.name) ~= "string" or #config.name == 0 then
    error("config.name must be a non-empty string")
  end

  validate_create(config.create)
end

function M.chat(contact, text)
  local c = get_contact_table(contact)
  local pane_id, was_created = ensure_pane_bound(c)

  local send = function()
    local ok, err = send_texts(pane_id, text)
    if not ok then
      error("Failed to send text: " .. err)
    end

    state.set_last_contact(c)
    return true
  end

  if was_created then
    vim.defer_fn(send, 150)
    return true
  else
    return send()
  end
end

function M.send_command(contact, cmd)
  -- local mode = vim.fn.mode()
  -- if mode:match('V') then
  --   local sline = vim.fn.line("'<")
  --   local eline = vim.fn.line("'>")
  --   local lines = vim.api.nvim_buf_get_text(0, sline - 1, 0, eline - 1, 999, {})
  --   local selection = table.concat(lines, "\n")
  --   if not selection or selection == '' then
  --     error("No visual selection available")
  --   end
  --   cmd = selection .. (cmd or '')
  -- elseif cmd == nil then
  --   cmd = ''
  -- end
  if cmd == nil then
    cmd = ''
  end

  local c = get_contact_table(contact)
  local pane_id, was_created = ensure_pane_bound(c)

  local send = function()
    local items = type(cmd) == "table" and cmd or { cmd }
    for _, item in ipairs(items) do
      local ok, err = tmux.send_text(pane_id, item)
      if not ok then
        error("Failed to send command: " .. err)
      end
    end

    local ok, err = tmux.send_enter(pane_id)
    if not ok then
      error("Failed to send Enter: " .. err)
    end

    state.set_last_contact(c)
    return true
  end

  if was_created then
    vim.defer_fn(send, 250)
    return true
  else
    return send()
  end
end

function M.clear_contact(contact)
  local c = get_contact_table(contact)
  if not c.pane_id then
    return true
  end

  local ok, err = tmux.clear_history(c.pane_id)
  if not ok then
    error("Failed to clear history: " .. err)
  end

  return true
end

function M.breakup(contact)
  local c = get_contact_table(contact)
  if c.pane_id then
    local ok, err = tmux.kill_pane(c.pane_id)
    if ok then
      c.pane_id = nil
    else
      if not err:find("no such pane") then
        error("Failed to kill pane: " .. err)
      end
    end
  end

  return true
end

function M.run_command(contact, tmux_cmd)
  local c = get_contact_table(contact)
  local pane_id = ensure_pane_bound(c)

  local ok, err = tmux.execute_tmux_command(tmux_cmd, pane_id)
  if not ok then
    error("Failed to execute tmux command: " .. err)
  end

  state.set_last_contact(c)
  return true
end

function M.create_contact(config)
  M.validate_config(config)

  local contact = {
    name = config.name,
    create = config.create,
    pane_id = nil,
    match_command = nil,
    breakup_on_exit = config_defaults.breakup_on_exit,
  }

  if config.match_command ~= nil then
    contact.match_command = config.match_command
  end

  if config.breakup_on_exit ~= nil then
    contact.breakup_on_exit = config.breakup_on_exit
  end

  return setmetatable(contact, { __index = M })
end

return M
