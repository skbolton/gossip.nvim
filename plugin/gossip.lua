vim.api.nvim_create_autocmd("VimLeavePre", {
  pattern = "*",
  callback = function()
    local state = require("gossip.state")
    local tmux = require("gossip.tmux")

    local all_contacts = state.get_all_contacts()
    for name, contact in pairs(all_contacts) do
      if contact.breakup_on_exit and contact.pane_id then
        local ok, err = tmux.kill_pane(contact.pane_id)
        if not ok and not err:find("no such pane") then
          error("Failed to kill pane: " .. err)
        end
      end
    end
  end,
})
