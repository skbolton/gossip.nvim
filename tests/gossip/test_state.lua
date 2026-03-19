local test = require("tests.gossip.test_lib")
local state = require("gossip.state")

test.describe("gossip.state", function()
  test.describe("register_contact", function()
    test.it("should register a new contact", function()
      local contact = { name = "test", create = "cmd" }
      state.register_contact(contact)
      test.assert.are.same(contact, state.get_contact("test"))
    end)

    test.it("should throw error for duplicate contact", function()
      local contact = { name = "dup", create = "cmd" }
      state.register_contact(contact)
      test.assert.has_error(function()
        state.register_contact({ name = "dup", create = "other" })
      end, "Contact already exists: dup")
    end)
  end)

  test.describe("get_contact", function()
    test.it("should return nil for non-existent contact", function()
      test.assert.are.same(nil, state.get_contact("nonexistent"))
    end)

    test.it("should return registered contact", function()
      local contact = { name = "gettest", create = "cmd" }
      state.register_contact(contact)
      test.assert.are.same(contact, state.get_contact("gettest"))
    end)
  end)

  test.describe("contact_exists", function()
    test.it("should return false for non-existent contact", function()
      test.assert.are.same(false, state.contact_exists("nonexistent"))
    end)

    test.it("should return true for existing contact", function()
      local contact = { name = "exists", create = "cmd" }
      state.register_contact(contact)
      test.assert.are.same(true, state.contact_exists("exists"))
    end)
  end)

  test.describe("last_contact", function()
    test.it("should return nil when no last contact", function()
      test.assert.are.same(nil, state.get_last_contact())
    end)

    test.it("should set and get last contact", function()
      local contact = { name = "last", create = "cmd" }
      state.set_last_contact(contact)
      test.assert.are.same(contact, state.get_last_contact())
    end)

    test.it("should throw error when setting nil", function()
      test.assert.has_error(function()
        state.set_last_contact(nil)
      end, "Cannot set last_contact to nil")
    end)
  end)
end)

return test.run_all()
