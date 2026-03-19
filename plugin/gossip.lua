local gossip = require('gossip')

vim.api.nvim_create_autocmd('VimLeave', {
  callback = function()
    local contacts = gossip.get_all_contacts()
    for _, contact in pairs(contacts) do
      if contact.breakup_on_exit and contact.pane_id then
        local ok, _ = pcall(function()
          gossip.breakup(contact.name)
        end)
      end
    end
  end
})

return gossip