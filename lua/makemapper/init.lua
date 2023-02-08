local M = {}

local default_opts = {
    prefix = "<leader>M"
}

local opts

local set_mappings = function(m)
    local mappings = m or {}
    for target, suffix in pairs(mappings) do
        vim.keymap.set("n", opts.prefix .. suffix, "! make " .. target, { desc = target })
    end
end

M.setup = function(o)
    opts = vim.tbl_deep_extend("force", {}, default_opts, o or {})

    -- TODO __if whichkey exists__
    -- will have to split opts.prefix appropriately first
    -- require("which-key").register({
    --     m = {
    --         name = "make"
    --     }
    -- }, { prefix = "<leader>" })

    set_mappings(require "makemapper.makefile".parse_mappings())
end

return M
