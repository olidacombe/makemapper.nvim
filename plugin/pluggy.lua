local pluggy = require "pluggy"

vim.api.nvim_create_user_command("Pluggy", function(opts)
end, {
    nargs = "?",
    range = 1,
})
