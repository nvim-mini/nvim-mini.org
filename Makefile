# Download 'mini.nvim' to render its content
_deps/mini.nvim:
	@mkdir -p _deps
	git clone --filter=blob:none https://github.com/nvim-mini/mini.nvim $@
	git -C _deps/mini.nvim checkout readme-reorg

mini_nvim: _deps/mini.nvim
	chmod u+x _scripts/mini_nvim.sh && _scripts/mini_nvim.sh
