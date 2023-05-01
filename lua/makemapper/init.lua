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

-- store parsed mappings so that we can remove old ones on refresh events
M._mappings = {}

local set_mappings = function(m)
    -- first clean up any existing
    for _, suffix in pairs(M._mappings) do
        vim.keymap.del("n", opts.prefix .. suffix)
    end
    local has_which_key, which_key = pcall(require, "which-key")
    if has_which_key then
        local slated_mappings = {}
        for _, suffix in pairs(M._mappings) do
            slated_mappings[opts.prefix .. suffix] = "which_key_ignore"
        end
        which_key.register(slated_mappings)
    end
    -- then set the new ones
    M._mappings = m or {}
    for target, suffix in pairs(M._mappings) do
        vim.keymap.set("n", opts.prefix .. suffix, M.make_runner(target), { desc = target })
    end
    if has_which_key then
        local mappings = {}
        for target, suffix in pairs(M._mappings) do
            mappings[opts.prefix .. suffix] = target
        end
        which_key.register(mappings)
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
