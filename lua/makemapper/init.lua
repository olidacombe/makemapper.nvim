local M = {}

local term_nvim = function(cmd)
    vim.cmd("vsplit | terminal " .. cmd)
end

-- TODO have options select different runners
local runner = term_nvim

-- given a general strategy for running commands, curry in "make {target}"
M.make_runner = function(target)
    return function()
        runner("make " .. target)
    end
end

local default_opts = {
    prefix = "<leader>m",
}

local opts

local set_mappings = function(m)
    local mappings = m or {}
    for target, suffix in pairs(mappings) do
        vim.keymap.set("n", opts.prefix .. suffix, M.make_runner(target), { desc = target })
    end
end

M.setup = function(o)
    opts = vim.tbl_deep_extend("force", {}, default_opts, o or {})

    local augroup = vim.api.nvim_create_augroup("Makemapper", {})

    local autocmd = vim.api.nvim_create_autocmd
    autocmd("BufEnter", {
        group = augroup,
        pattern = "*",
        callback = function()
            set_mappings(require("makemapper.makefile").parse_mappings())
        end
    })
end

return M
