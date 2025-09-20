# Download 'mini.nvim' to render its content
_deps/mini.nvim:
	@mkdir -p _deps
	git clone --filter=blob:none https://github.com/nvim-mini/mini.nvim $@

mini_nvim_readmes: _deps/mini.nvim
	chmod u+x _scripts/mini_nvim_readmes.sh && _scripts/mini_nvim_readmes.sh
