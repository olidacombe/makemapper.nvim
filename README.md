# MakeMapper

This aims to make project-specific keymappings for `make` targets trivial
by means of parsing them from comments affixed to make targets in your
`Makefile`.

There is also a [telescope](https://github.com/nvim-telescope/telescope.nvim)
extension to run make targets from a picker.


## Example

Annotate your `Makefile` with comments containing `nvim_map(...)`:

```make
# nvim_map(l)
lint:
	echo linting stuff...

test: # nvim_map(t)
    echo running tests...

no_mapping: # this target doesn't get an automatic keymap
```

If the above `Makefile` is in the root of your project, then the following
normal-mode keymaps are automatically created:

```
<leader>ml -> `make lint`
<leader>mt -> `make test`
```

# Installation

## Packer

```lua
use('olidacombe/makemapper')
```

# Setup

```lua
require("makemapper").setup()
```

# Telescope

To register the `makemapper` telescope extension, load it as follows:

```lua
-- Make `:Telescope makemapper` available
require('telescope').load_extension('makemapper')
```

# Configuration

You can override settings in `setup`:

```lua
require("makemapper").setup({
    prefix = "<leader>m", -- the prefix applied to all keymaps generated from annotations
})
```

# TODO

+ Provide an option to change the annotation from `nvim_map(.*)` to something user-defined.
