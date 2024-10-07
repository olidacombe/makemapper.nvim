local M = {}

local term_nvim = function(cmd)
    vim.cmd("vsplit | terminal " .. cmd)
end

-- TODO have options select different runners
local runner = term_nvim

-- given a general strategy for running commands, curry in "make {target}"
M.make_runner = function(target, cwd)
    return function()
        runner("cd " .. cwd .. "; make " .. target)
    end
end

local default_opts = {
    prefix = "<leader>m",
}

local opts

-- store parsed mappings so that we can remove old ones on refresh events
M._mappings = {}

local set_mappings = function(m, cwd)
    -- first clean up any existing
    for _, suffix in pairs(M._mappings) do
        vim.keymap.del("n", opts.prefix .. suffix)
    end
    -- then set the new ones
    M._mappings = m or {}
    for target, suffix in pairs(M._mappings) do
        vim.keymap.set("n", opts.prefix .. suffix, M.make_runner(target, cwd), { desc = target })
    end
end

M.setup = function(o)
    -- short-circuit if there's no make parser
    -- TODO print a warning?
    if not vim.treesitter.language.get_lang "make" then
        return
    end

    opts = vim.tbl_deep_extend("force", {}, default_opts, o or {})

    local augroup = vim.api.nvim_create_augroup("Makemapper", {})

    local autocmd = vim.api.nvim_create_autocmd
    autocmd("BufEnter", {
        group = augroup,
        pattern = "*",
        callback = function()
            vim.schedule(function()
                set_mappings(require("makemapper.makefile").parse_mappings())
            end)
        end,
    })

    autocmd("BufWritePost", {
        group = augroup,
        pattern = "Makefile",
        callback = function()
            vim.schedule(function()
                set_mappings(require("makemapper.makefile").parse_mappings())
            end)
        end,
    })
end

return M
