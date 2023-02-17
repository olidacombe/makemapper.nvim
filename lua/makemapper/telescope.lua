local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local parse_targets = require("makemapper.makefile").parse_targets

local M = {}

local telescope = function(opts)
    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = "Target",
            finder = finders.new_dynamic {
                fn = function(_prompt)
                    -- map target -> runner function table to
                    -- list of { target, runner } tables
                    local results = {}
                    for target, runner in pairs(parse_targets()) do
                        table.insert(results, { target, runner })
                    end
                    return results
                end,
                entry_maker = function(entry)
                    return {
                        value = entry[2],
                        display = entry[1],
                        ordinal = entry[1],
                    }
                end,
            },
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    if not selection then
                        return
                    end
                    selection.value()
                end)
                return true
            end,
        })
        :find()
end

M.telescope = function()
    telescope(require("telescope.themes").get_dropdown {})
end

-- make this module callable
setmetatable(M, {
    __call = M.telescope,
})

return M
