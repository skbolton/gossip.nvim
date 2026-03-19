--- Low-level tmux command wrappers.
-- @module gossip.tmux
-- @local

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
  local output, err = execute_tmux_sync({"tmux", "display-message", "-p", "#{pane_id}"})
  if err then
    return nil, err
  end
  return output, nil
end

function M.get_pane_ids()
  local output, err = execute_tmux_sync({"tmux", "list-panes", "-s", "-F", "#{pane_id}"})
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
  local _, err = execute_tmux_sync({"tmux", "send-keys", "-t", pane_id, text})
  if err then
    return false, err
  end
  return true, nil
end

function M.send_enter(pane_id)
  local _, err = execute_tmux_sync({"tmux", "send-keys", "-t", pane_id, "Enter"})
  if err then
    return false, err
  end
  return true, nil
end

function M.clear_history(pane_id)
  local _, err = execute_tmux_sync({"tmux", "clear-history", "-t", pane_id})
  if err then
    return false, err
  end
  return true, nil
end

function M.kill_pane(pane_id)
  local _, err = execute_tmux_sync({"tmux", "kill-pane", "-t", pane_id})
  if err then
    return false, err
  end
  return true, nil
end

function M.build_create_command(create)
  local cmd_parts = { "tmux" }

  if type(create) == "string" then
    table.insert(cmd_parts, create)
    table.insert(cmd_parts, "-d")
  elseif type(create) == "table" then
    local key = next(create)
    local opts = create[key]

    if key == "split" then
      table.insert(cmd_parts, "split")
      if opts.dir then
        table.insert(cmd_parts, "-" .. opts.dir)
      else
        table.insert(cmd_parts, "-h")
      end
      table.insert(cmd_parts, "-d")
      if opts.size then
        table.insert(cmd_parts, "-l")
        table.insert(cmd_parts, opts.size)
      end
      if opts.command then
        table.insert(cmd_parts, opts.command)
      end
    elseif key == "window" then
      table.insert(cmd_parts, "new-window")
      if opts.name then
        table.insert(cmd_parts, "-n")
        table.insert(cmd_parts, opts.name)
      end
      if opts.command then
        table.insert(cmd_parts, opts.command)
      end
    else
      error("create must have key 'split' or 'window'")
    end
  else
    error("create must be a string or table")
  end

  return cmd_parts
end

function M.execute_create_command(create)
  local full_cmd = M.build_create_command(create)
  local output, err = execute_tmux_sync(full_cmd)
  if err then
    return nil, err
  end
  return output, nil
end

function M.execute_tmux_command(tmux_cmd, pane_id)
  local cmd_parts = {}
  local needs_target = false
  for part in tmux_cmd:gmatch("%S+") do
    table.insert(cmd_parts, part)
  end
  
  local last = cmd_parts[#cmd_parts]
  if last == "-t" then
    needs_target = true
    table.insert(cmd_parts, pane_id)
  elseif not vim.list_contains(cmd_parts, "-t") then
    table.insert(cmd_parts, "-t")
    table.insert(cmd_parts, pane_id)
  end
  
  local _, err = execute_tmux_sync(vim.list_extend({"tmux"}, cmd_parts))
  if err then
    return false, err
  end
  return true, nil
end

return M
