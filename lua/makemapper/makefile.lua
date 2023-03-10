local make_runner = require("makemapper").make_runner

local M = {}

-- see if the file exists
local file_exists = function(file)
    local f = io.open(file, "rb")
    if f then
        f:close()
    end
    return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
local lines_from = function(file)
    if not file_exists(file) then
        return nil
    end
    local lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

-- load Makefile into a buffer and return the id,
-- or nil if not found
M.makefile_buffer = function()
    local cwd = vim.fn.getcwd()
    local makefile_path = cwd .. "/Makefile"
    local lines = lines_from(makefile_path)
    if lines == nil then
        return
    end
    -- create unlisted scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)
    -- load lines of Makefile into it
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    -- return handle
    return buf
end

M._parse_makefile = function()
    local makefile = M.makefile_buffer()
    if not makefile then
        return {}
    end
    return M.parse_buffer(makefile)
end

M.parse_targets = function()
    P "PARSE TARGETS"
    return M._parse_makefile().targets or {}
end

-- finds annotations in `Makefile` and returns a table of
-- suffix -> target
-- assignments
M.parse_mappings = function()
    return M._parse_makefile().mappings or {}
end

local node_text = function(node, ctx)
    local r1, c1, r2, c2 = node:range()
    local text = vim.api.nvim_buf_get_text(ctx.bufnr or 0, r1, c1, r2, c2, {})
    -- get first line
    return table.remove(text)
end

M.parse_rule_node = function(node, ctx)
    ctx = ctx or {}
    ctx.mappings = ctx.mappings or {}
    ctx.targets = ctx.targets or {}
    ctx.bufnr = ctx.bufnr or 0

    local target
    for child in node:iter_children() do
        local type = child:type()
        if type == "comment" then
            M.parse_comment_node(child, ctx)
        elseif type == "targets" then
            target = node_text(child, ctx)
        end
    end
    if target then
        ctx.targets[target] = make_runner(target)
        ctx.mappings[target] = ctx.current_mapping_annotation
        ctx.current_mapping_annotation = nil
    end
end

M.parse_comment = function(str)
    local _, _, annotation = string.find(str, "nvim_map%((%S+)%)")
    return annotation
end

M.parse_comment_node = function(node, ctx)
    ctx = ctx or {}
    local annotation = M.parse_comment(node_text(node, ctx) or "")
    -- update current_mapping_annotation if the current comment has valid content
    ctx.current_mapping_annotation = annotation or ctx.current_mapping_annotation
end

M.parse_node = function(node, ctx)
    ctx = ctx or {}
    local type = node:type()

    if type == "comment" then
        M.parse_comment_node(node, ctx)
    elseif type == "rule" then
        M.parse_rule_node(node, ctx)
    else
        -- whatever annotation we may have last seen is not for this node
        -- or the next
        ctx.current_mapping_annotation = nil
    end
end

-- get a table of mappings from a buffer
-- with entries of the form `target = suffix`
M.parse_buffer = function(bufnr)
    local tsparser = vim.treesitter.get_parser(bufnr or 0, "make")
    local trees = tsparser:parse()
    local mappings = {}
    local targets = {}
    if #trees < 1 then
        return mappings
    end
    local tree = trees[1]

    local root = tree:root()
    local ctx = { bufnr = bufnr, mappings = mappings, targets = targets }
    for node in root:iter_children() do
        M.parse_node(node, ctx)
    end

    return ctx
end

return M
