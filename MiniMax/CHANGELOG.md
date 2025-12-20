_Generated from the `main` branch of 'MiniMax'_

## 2025-12-20 {#2025-12-20}

- Start using 'mini.cmdline'.

## 2025-12-16 {#2025-12-16}

- Update 'nvim-treesitter/nvim-treesitter' plugin to not explicitly use `main` branch as it is now the default.

- Update 'mason-org/mason.nvim' example to use `now_if_args` instead of `later`. Otherwise LSP server installed via Mason will not yet be available if Neovim is started as `nvim -- path/to/file`.

## 2025-11-22 {#2025-11-22}

- Update `<Leader>fs` mapping to use `"workspace_symbol_live"` scope for `:Pick lsp` instead of `"workspace_symbol"`

## 2025-10-16 {#2025-10-16}

- Move `now_if_args` startup helper to 'init.lua' as `_G.Config.now_if_args` to be directly usable from other config files.

- Enable 'mini.misc' behind `now_if_args` instead of `now`. Otherwise `setup_auto_root()` and `setup_restore_cursor()` don't work on initial file(s) if Neovim is started as `nvim -- path/to/file`.

## 2025-10-13 {#2025-10-13}

- Initial release.
