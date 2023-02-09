local makefile = require("makemapper.makefile")

local test_buffer = function(lines)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    return buf
end

describe("parse_comment", function()
    it("basically works", function()
        local result = makefile.parse_comment("# my comment nvim_map(ab)")
        assert.equal(result, "ab")
    end)
end)
