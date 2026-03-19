local test = require("tests.gossip.test_lib")
local contact = require("gossip.contact")

test.describe("gossip.contact", function()
  test.describe("validate_config", function()
    test.it("should accept valid config with name and create", function()
      local config = { name = "test", create = "tmux split-window" }
      test.assert.has_no_error(function()
        contact.validate_config(config)
      end)
    end)

    test.it("should reject non-table config", function()
      test.assert.has_error(function()
        contact.validate_config("string")
      end, "config must be a table, got string")
    end)

    test.it("should reject nil config", function()
      test.assert.has_error(function()
        contact.validate_config(nil)
      end, "config must be a table, got nil")
    end)

    test.it("should reject empty name", function()
      test.assert.has_error(function()
        contact.validate_config({ name = "", create = "cmd" })
      end, "config.name must be a non-empty string")
    end)

    test.it("should reject non-string name", function()
      test.assert.has_error(function()
        contact.validate_config({ name = 123, create = "cmd" })
      end, "config.name must be a non-empty string")
    end)

    test.it("should reject empty create", function()
      test.assert.has_error(function()
        contact.validate_config({ name = "test", create = "" })
      end, "config.create must be a non-empty string")
    end)

    test.it("should reject non-string create", function()
      test.assert.has_error(function()
        contact.validate_config({ name = "test", create = 123 })
      end, "config.create must be a non-empty string")
    end)

    test.it("should reject find=true without match_command", function()
      test.assert.has_error(function()
        contact.validate_config({ name = "test", create = "cmd", find = true })
      end, "config.match_command must be a string when find=true")
    end)

    test.it("should accept find=true with match_command", function()
      local config = { name = "test", create = "cmd", find = true, match_command = "bash" }
      test.assert.has_no_error(function()
        contact.validate_config(config)
      end)
    end)
  end)

  test.describe("create_contact", function()
    test.it("should create contact with defaults", function()
      local contact_table = contact.create_contact({ name = "test", create = "cmd" })
      test.assert.are.same({
        name = "test",
        create = "cmd",
        pane_id = nil,
        find = false,
        match_command = nil,
        breakup_on_exit = false,
      }, contact_table)
    end)

    test.it("should override defaults with config values", function()
      local contact_table = contact.create_contact({
        name = "test",
        create = "cmd",
        find = true,
        match_command = "vim",
        breakup_on_exit = true,
      })
      test.assert.are.same({
        name = "test",
        create = "cmd",
        pane_id = nil,
        find = true,
        match_command = "vim",
        breakup_on_exit = true,
      }, contact_table)
    end)

    test.it("should throw on invalid config", function()
      test.assert.has_error(function()
        contact.create_contact({ name = "", create = "cmd" })
      end)
    end)
  end)
end)

return test.run_all()
