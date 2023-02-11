local makemapper = require("makemapper.telescope")

return require("telescope").register_extension {
    setup = function(_ext_config, _config)
        -- access extension config and user config
    end,
    exports = {
        makemapper = makemapper
    },
}
