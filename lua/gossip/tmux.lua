local M = {}

local function execute_tmux_sync(args)
  local result = vim.system(args, { text = true }):wait()
  if result.code ~= 0 then
    return nil, (result.stderr:gsub("%s+$", "") or ("command failed with exit code " .. result.code))
  end
  return result.stdout:gsub("%s+$", ""), nil
end

function M.list_panes(session)
  local args = { "tmux", "list-panes", "-s", "-F", "#{pane_id} #{pane_current_command}" }
  if session then
    args = { "tmux", "list-panes", "-t", session, "-F", "#{pane_id} #{pane_current_command}" }
  end
  local output, err = execute_tmux_sync(args)
  if err then
    return nil, err
  end
  return output
end

function M.find_pane_by_command(command_pattern, session)
  local output, err = M.list_panes(session)
  if not output then
    return nil, err
  end

  for line in output:gmatch("[^\r\n]+") do
    local pane_id, current_command = line:match("^(%S+)%s+(.+)$")
    if pane_id and current_command and current_command:find(command_pattern, 1, true) then
      return pane_id
    end
  end

  return nil, "No pane found matching: " .. command_pattern
end

function M.capture_pane_id()
  local output, err = execute_tmux_sync({ "tmux", "display-message", "-p", "#{pane_id}" })
  if err then
    return nil, err
  end
  return output, nil
end

function M.get_pane_ids()
  local output, err = execute_tmux_sync({ "tmux", "list-panes", "-s", "-F", "#{pane_id}" })
  if err then
    return nil, err
  end
  local ids = {}
  for line in output:gmatch("[^\r\n]+") do
    if line and #line > 0 then
      table.insert(ids, line)
    end
  end
  return ids
end

function M.find_new_pane_id(before_ids)
  local after_ids = M.get_pane_ids()
  if not after_ids then
    return nil, "Failed to get pane IDs after creation"
  end
  for _, id in ipairs(after_ids) do
    local found = false
    for _, before_id in ipairs(before_ids) do
      if id == before_id then
        found = true
        break
      end
    end
    if not found then
      return id
    end
  end
  return nil, "No new pane found"
end

function M.send_text(pane_id, text)
  local _, err = execute_tmux_sync({ "tmux", "send-keys", "-t", pane_id, text })
  if err then
    return false, err
  end
  return true, nil
end

function M.send_enter(pane_id)
  local _, err = execute_tmux_sync({ "tmux", "send-keys", "-t", pane_id, "Enter" })
  if err then
    return false, err
  end
  return true, nil
end

function M.send_keys(pane_id, keys)
  local args = { "tmux", "send-keys", "-t", pane_id }
  if type(keys) == "table" then
    for _, key in ipairs(keys) do
      table.insert(args, key)
    end
  else
    table.insert(args, keys)
  end
  local _, err = execute_tmux_sync(args)
  if err then
    return false, err
  end
  return true, nil
end

function M.clear_history(pane_id)
  local _, err = execute_tmux_sync({ "tmux", "clear-history", "-t", pane_id })
  if err then
    return false, err
  end
  return true, nil
end

function M.kill_pane(pane_id)
  local _, err = execute_tmux_sync({ "tmux", "kill-pane", "-t", pane_id })
  if err then
    return false, err
  end
  return true, nil
end

function M.build_create_command(create)
  local cmd_parts = { "tmux" }

  if type(create) == "string" then
    table.insert(cmd_parts, "split-window")
    local parts = {}
    for part in create:gmatch("%S+") do
      table.insert(parts, part)
    end
    for _, part in ipairs(parts) do
      table.insert(cmd_parts, part)
    end
  elseif type(create) == "table" then
    local keys = {}
    for k, _ in pairs(create) do
      table.insert(keys, k)
    end

    local key = keys[1]
    if key == "split" then
      table.insert(cmd_parts, "split-window")
      local s = create.split
      if s.dir then
        table.insert(cmd_parts, "-" .. s.dir)
      end
      if s.size then
        table.insert(cmd_parts, "-l")
        table.insert(cmd_parts, s.size)
      end
      if s.command then
        table.insert(cmd_parts, s.command)
      end
    elseif key == "window" then
      table.insert(cmd_parts, "new-window")
      local w = create.window
      if w.name then
        table.insert(cmd_parts, "-n")
        table.insert(cmd_parts, w.name)
      end
      if w.command then
        table.insert(cmd_parts, w.command)
      end
    end
  end

  return cmd_parts
end

function M.execute_create_command(create)
  local cmd_parts = M.build_create_command(create)
  return execute_tmux_sync(cmd_parts)
end

function M.execute_tmux_command(cmd, pane_id)
  local args = { "tmux" }
  for part in cmd:gmatch("%S+") do
    table.insert(args, part)
  end
  if pane_id and not cmd:find("%-t") then
    table.insert(args, "-t")
    table.insert(args, pane_id)
  end
  return execute_tmux_sync(args)
end

function M.validate_pane_exists(pane_id)
  local _, err = execute_tmux_sync({ "tmux", "list-panes", "-t", pane_id })
  if err then
    return false, err
  end
  return true, nil
end

function M.zoom_pane(pane_id)
  local _, err = execute_tmux_sync({ "tmux", "choose-client", "-t", pane_id, "-z" })
  if err then
    return false, err
  end
  return true, nil
end

return M
