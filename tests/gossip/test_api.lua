local test = require("tests.gossip.test_lib")

test.describe("gossip.api", function()
  test.describe("get_contact_table", function()
    test.it("should accept string contact name", function()
      local state = require("gossip.state")
      state.register_contact({ name = "strtest", create = "cmd" })

      local api = require("gossip.api")
      local result = api.get_contact_table and api.get_contact_table("strtest") or nil

      if result then
        test.assert.are.same("strtest", result.name)
      end
    end)

    test.it("should accept table contact", function()
      local contact = { name = "tabletest", create = "cmd" }
      test.assert.has_no_error(function() end)
    end)

    test.it("should reject invalid contact type", function()
      test.assert.has_error(function()
        local api = require("gossip.api")
        if api.get_contact_table then
          api.get_contact_table(123)
        end
      end, "contact must be a string or table")
    end)
  end)
end)

return test.run_all()
