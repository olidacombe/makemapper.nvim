local makemapper = require "makemapper"

vim.api.nvim_create_user_command("Makemapper", function(opts) end, {
    nargs = "?",
    range = 1,
})
