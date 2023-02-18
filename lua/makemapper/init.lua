local M = {}

local runners = {
    nvim_vsplit = function(cmd)
        vim.cmd("vsplit | terminal " .. cmd)
    end,
    harpoon_tmux = function(cmd)
        require("harpoon.tmux").sendCommand(1, cmd .. "\n")
    end,
}

local runner

-- given a general strategy for running commands, curry in "make {target}"
M.make_runner = function(target)
    return function()
        runner("make " .. target)
    end
end

local default_opts = {
    prefix = "<leader>m",
    runner = "nvim_vsplit",
}

local opts

local set_mappings = function(m)
    local mappings = m or {}
    for target, suffix in pairs(mappings) do
        vim.keymap.set("n", opts.prefix .. suffix, M.make_runner(target), { desc = target })
    end
end

local get_runner = function(spec)
    if type(spec) == "function" then
        return spec
    end
    return runners[spec]
end

M.set_runner = function(spec)
    runner = get_runner(spec) or get_runner(default_opts.runner)
end

M.setup = function(o)
    opts = vim.tbl_deep_extend("force", {}, default_opts, o or {})

    M.set_runner(opts.runner)
    set_mappings(require("makemapper.makefile").parse_mappings())
end

return M
