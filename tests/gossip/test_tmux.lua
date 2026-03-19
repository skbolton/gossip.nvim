local test = require("tests.gossip.test_lib")

local original_system = vim.system
local mock_results = {}

test.describe("gossip.tmux", function()
  test.describe("list_panes", function()
    test.it("should return pane list from tmux", function()
      mock_results["list-panes"] = "%1.0 bash\n%1.1 vim\n"
      vim.system = function(args, opts)
        return {
          wait = function() return { code = 0, stdout = mock_results["list-panes"], stderr = "" } end
        }
      end

      local tmux = require("gossip.tmux")
      local output, err = tmux.list_panes()
      test.assert.has_no_error(function() end)
      test.assert.are.same(mock_results["list-panes"], output)
    end)
  end)

  test.describe("find_pane_by_command", function()
    test.it("should find pane matching command", function()
      mock_results["list-panes"] = "%1.0 bash\n%1.1 vim\n"
      vim.system = function(args, opts)
        return {
          wait = function() return { code = 0, stdout = mock_results["list-panes"], stderr = "" } end
        }
      end

      local tmux = require("gossip.tmux")
      local pane_id, err = tmux.find_pane_by_command("vim")
      test.assert.are.same("%1.1", pane_id)
    end)

    test.it("should return nil when no match", function()
      mock_results["list-panes"] = "%1.0 bash\n%1.1 vim\n"
      vim.system = function(args, opts)
        return {
          wait = function() return { code = 0, stdout = mock_results["list-panes"], stderr = "" } end
        }
      end

      local tmux = require("gossip.tmux")
      local pane_id, err = tmux.find_pane_by_command("nonexistent")
      test.assert.are.same(nil, pane_id)
      test.assert.assert(err:find("No pane found matching"))
    end)
  end)

  test.describe("capture_pane_id", function()
    test.it("should return current pane id", function()
      vim.system = function(args, opts)
        return {
          wait = function() return { code = 0, stdout = "%1.0\n", stderr = "" } end
        }
      end

      local tmux = require("gossip.tmux")
      local pane_id, err = tmux.capture_pane_id()
      test.assert.are.same("%1.0", pane_id)
    end)
  end)

  test.describe("send_text", function()
    test.it("should send text to pane", function()
      vim.system = function(args, opts)
        return {
          wait = function() return { code = 0, stdout = "", stderr = "" } end
        }
      end

      local tmux = require("gossip.tmux")
      local ok, err = tmux.send_text("%1.0", "hello world")
      test.assert.are.same(true, ok)
    end)

    test.it("should escape quotes in text", function()
      local captured_cmd = nil
      vim.system = function(args, opts)
        captured_cmd = table.concat(args, " ")
        return {
          wait = function() return { code = 0, stdout = "", stderr = "" } end
        }
      end

      local tmux = require("gossip.tmux")
      tmux.send_text("%1.0", 'say "hello"')
      test.assert.assert(captured_cmd:find('\\"hello\\"'))
    end)
  end)

  test.describe("send_enter", function()
    test.it("should send Enter key", function()
      vim.system = function(args, opts)
        return {
          wait = function() return { code = 0, stdout = "", stderr = "" } end
        }
      end

      local tmux = require("gossip.tmux")
      local ok, err = tmux.send_enter("%1.0")
      test.assert.are.same(true, ok)
    end)
  end)

  test.describe("clear_history", function()
    test.it("should clear pane history", function()
      vim.system = function(args, opts)
        return {
          wait = function() return { code = 0, stdout = "", stderr = "" } end
        }
      end

      local tmux = require("gossip.tmux")
      local ok, err = tmux.clear_history("%1.0")
      test.assert.are.same(true, ok)
    end)
  end)

  test.describe("kill_pane", function()
    test.it("should kill pane", function()
      vim.system = function(args, opts)
        return {
          wait = function() return { code = 0, stdout = "", stderr = "" } end
        }
      end

      local tmux = require("gossip.tmux")
      local ok, err = tmux.kill_pane("%1.0")
      test.assert.are.same(true, ok)
    end)
  end)

  test.describe("execute_tmux_command", function()
    test.it("should execute arbitrary tmux command", function()
      vim.system = function(args, opts)
        return {
          wait = function() return { code = 0, stdout = "", stderr = "" } end
        }
      end

      local tmux = require("gossip.tmux")
      local ok, err = tmux.execute_tmux_command("send-keys C-c", "%1.0")
      test.assert.are.same(true, ok)
    end)
  end)
end)

vim.system = original_system
return test.run_all()
