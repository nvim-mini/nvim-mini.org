.PHONY: mini.nvim MiniMax

# mini.nvim
_deps/mini.nvim:
	@mkdir -p _deps
	git clone --filter=blob:none https://github.com/nvim-mini/mini.nvim $@

mini.nvim: _deps/mini.nvim
	chmod u+x _scripts/mini_nvim.sh && _scripts/mini_nvim.sh

# MiniMax
_deps/MiniMax:
	@mkdir -p _deps
	git clone --filter=blob:none https://github.com/nvim-mini/MiniMax $@

MiniMax: _deps/MiniMax
	chmod u+x _scripts/minimax.sh && _scripts/minimax.sh

# Sync
sync: mini.nvim MiniMax
	chmod u+x _scripts/sync.sh && _scripts/sync.sh
