local test = require("tests.gossip.test_lib")

test.describe("Gossip Plugin - Full Test Suite", function()
  require("tests.gossip.test_contact")
  require("tests.gossip.test_state")
  require("tests.gossip.test_tmux")
end)

return test.run_all()
