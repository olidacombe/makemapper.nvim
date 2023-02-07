.PHONY: test

lint: # nvim_map(l)
	luacheck lua/makemapper

test: # nvim_map(t)
	nvim --headless --noplugin \
	-u scripts/minimal_init.vim \
	-c "PlenaryBustedDirectory tests/plenary { minimal_init = './scripts/minimal_init.vim' }"
