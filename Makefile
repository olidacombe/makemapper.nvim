.PHONY: test

# nvim_map(l)
lint:
	luacheck lua/makemapper

test: # nvim_map(t)
	nvim --headless \
	-u tests/init.lua \
	-c "PlenaryBustedDirectory tests/plenary { minimal_init = 'tests//init.lua' }"

blost:
	# thigeh
	echo ok
