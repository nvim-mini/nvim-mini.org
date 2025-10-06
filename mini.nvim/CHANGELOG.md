_Generated from the `main` branch of 'mini.nvim'_

This is the log of changes for past and current development versions. It lists changes in user-facing functionality per module (or all modules) and type.

There are following change types:

- `Evolve` - change in previously intended functionality *while* adding a new one.
- `Refine` - change in previously intended functionality *without* adding new one. This is usually described as a "breaking change", but used here in a sense that it might break user's expectations about existing functionality.
- `Expand` - adding new functionality without affecting existing ones. This is essentially new features.

# Version 0.17.0-dev {#v0.17.0}

## All {#v0.17.0-all}

### Evolve {#v0.17.0-all-evolve}

- Move repository hosting from personal 'echasnovski' GitHub account to the 'nvim-mini' organization. All `git pull` and `git clone` should be automatically redirected from previous to new locations without breaking user configurations. Yet updating source links to point to new locations (like `'echasnovski/mini.nvim'` -> `'nvim-mini/mini.nvim'` and standalone repos) is recommended.

    This change is made to improve long term project stability. See more details [here](https://github.com/nvim-mini/mini.nvim/discussions/1970).

- Start setting custom Neovim method implementation during `setup()` (if module provides one). This is usually the expected behavior for majority of use cases and should improve "out of the box" experience. Modules should still export a function to manually adjust the implementation.

    It is a breaking change only if the implementation was not explicitly used. Can still be done if set or restored *after* calling module's `setup()`.

    Affected modules:

    - 'mini.notify' sets `vim.notify`.
    - 'mini.pick' sets `vim.ui.select`.

### Refine {#v0.17.0-all-refine}

- Stop official support of Neovim 0.8.

### Expand {#v0.17.0-all-expand}

- Add new bundled color schemes based on 'mini.hues':
    - `miniwinter`: "icy winter" palette with azure background.
    - `minispring`: "blooming spring" palette with green background.
    - `minisummer`: "hot summer" palette with brown/yellow background.
    - `miniautumn`: "cooling autumn" palette with purple background.

## mini.ai {#v0.17.0-mini.ai}

### Refine {#v0.17.0-mini.ai-refine}

- Update `gen_spec.treesitter()` to have `use_nvim_treesitter = false` as default option value (instead of `true`). It used to implement more advanced behavior, but as built-in `vim.treesitter` is capable enough, there is no need in extra dependency. The option will be removed after the release.

### Expand {#v0.17.0-mini.ai-expand}

- Add `gen_spec.user_prompt` that acts the same as `?` built-in textobject. It can be used for using this textobject under another identifier.

## mini.basics {#v0.17.0-mini.basics}

### Refine {#v0.17.0-mini.basics-refine}

- Change default value of `options.win_border` to be `'auto'`.

### Expand {#v0.17.0-mini.basics-expand}

- Update `options.win_border` to allow value `'auto'` which infers target 'fillchars' values from 'winborder' option.

## mini.completion {#v0.17.0-mini.completion}

### Evolve {#v0.17.0-mini.completion-evolve}

- Update `setup()` to remove "t" flag from 'complete' option (if not previously set and fallback action is default) as it leads to visible lags.

### Expand {#v0.17.0-mini.completion-expand}

- Add `MiniCompletionWindowOpen` and `MiniCompletionWindowUpdate` events.

- Add support for highlighting LSP item label via setting `abbr_hlgroup` field as part of an LSP item (like inside `config.lsp_completion.process_items`).

## mini.clue {#v0.17.0-mini.clue}

### Expand {#v0.17.0-mini.clue-expand}

- Add `gen_clues.square_brackets` to generate clues for `[` and `]` keys. By @TheLeoP, PR #1937.

## mini.diff {#v0.17.0-mini.diff}

### Expand {#v0.17.0-mini.diff-expand}

- Add support for working with files containing BOM bytes.

## mini.extra {#v0.17.0-mini.extra}

### Expand {#v0.17.0-mini.extra-expand}

- Add `pickers.colorschemes` picker. By @pkazmier, PR #1789.

- Add `<C-e>` mapping for `pickers.history` picker to edit commands or searches in cmdline. By @TheLeoP, PR #1960.

## mini.files {#v0.17.0-mini.files}

### Refine {#v0.17.0-mini.files-refine}

- Ensure preview window is never hidden, even if cursor is on the line for a not (yet) existing file system entry. This reduces flickering of preview window when creating new files in Insert mode.

## mini.hues {#v0.17.0-mini.hues}

### Refine {#v0.17.0-mini.hues-refine}

- Make black (0 and 8) and white (7 and 15) colors for built-in terminal different from regular background and foreground. This improves color coverage and does not affect default uncolored text (it is highlighted as `Normal`).

### Expand {#v0.17.0-mini.hues-expand}

- Add `get_palette()` function.

## mini.jump {#v0.17.0-mini.jump}

### Expand {#v0.17.0-mini.jump-expand}

- Trigger dedicated events during steps of jumping life cycle. See `:h MiniJump-events`.

## mini.jump2d {#v0.17.0-mini.jump2d}

### Evolve {#v0.17.0-mini.jump2d-evolve}

- Update `builtin_opts.word_start` to use built-in notion of "keyword" (see `:h 'iskeyword'`) when computing word start.

### Refine {#v0.17.0-mini.jump2d-refine}

- Move `gen_xxx_spotter` into separate `gen_spotter` table for consistency with other modules:
    - `gen_pattern_spotter` -> `gen_spotter.pattern`
    - `gen_union_spotter` -> `gen_spotter.union`

    The `gen_xxx_spotter` functions will work (with warning) until at least next release.

- Not focusable windows are now ignored when computing jump spots.

### Expand {#v0.17.0-mini.jump2d-expand}

- Add `gen_spotter.vimpattern()` that can generate spotter based on Vimscript (not Lua) pattern.

## mini.misc {#v0.17.0-mini.misc}

### Expand {#v0.17.0-mini.misc-expand}

- Update `zoom()` to return whether current buffer is zoomed in. By @loichyan, PR #1954.

## mini.pick {#v0.17.0-mini.pick}

### Expand {#v0.17.0-mini.pick-expand}

- "Paste" action now supports special registers: `<C-w>` (word at cursor), `<C-a>` (WORD at cursor), `<C-l>` (line at cursor), `<C-f>` (filename at cursor).

## mini.sessions {#v0.17.0-mini.sessions}

### Refine {#v0.17.0-mini.sessions-refine}

- Update `read()` to write currently read session only if `MiniSessions.config.autowrite` is set to `true`.

## mini.surround {#v0.17.0-mini.surround}

### Evolve {#v0.17.0-mini.surround-evolve}

- Stop creating `update_n_lines` mapping: it occupies "mapping real estate" while being rarely needed and straightforward to create manually using `MiniSurround.update_n_lines()`.

### Refine {#v0.17.0-mini.surround-refine}

- Update `gen_spec.inpuf.treesitter()` to have `use_nvim_treesitter = false` as default option value (instead of `true`). It used to implement more advanced behavior, but as built-in `vim.treesitter` is capable enough, there is no need in extra dependency. The option will be removed after the release.

## mini.test {#v0.17.0-mini.test}

### Refine {#v0.17.0-mini.test-refine}

- Soft deprecate `ignore_lines` option in `expect.reference_screenshot()` in favor of more capable `ignore_text` and `ignore_attr` options. For example, `ignore_lines = { 1 }` is the same as supplying both `ignore_text = { 1 }` and `ignore_attr = { 1 }`.

    It will work at least until the next release, after which its support will be removed. Sorry for the inconvenience.

### Expand {#v0.17.0-mini.test-expand}

- Update `expect.reference_screenshot()` to support separate ignoring of text and attribute screenshot data via new `ignore_text` and `ignore_attr` options.


# Version 0.16.0 {#v0.16.0}

## All {#v0.16.0-all}

### Evolve {#v0.16.0-all-evolve}

- Unify behavior of floating windows:
    - Truncate title/footer from left if it is too wide.
    - Set default title if window is allowed to have border.
    - Use single space padding for default title/footer.
    - Use 'single' as default window border in modules where it can be configured. On Neovim>=0.11 also respect non-empty 'winborder' option with lower precedence than explicitly configured value for the module.

- Unify how module-related buffers are named: `mini<module-name>://<buffer-number>/<useful-info>`. This structure allows creating identifiable, reasonably unique, and useful buffer names. This is a user facing change because in some cases the shown buffer's name will change (like in statusline of opened 'mini.starter' buffer or output of `:buffers!`).

- Stop forcing recommended option values behind `set_vim_settings` config setting. Instead set them automatically in `setup()`. If it is not essential, do so only if it was not set by user/plugin beforehand (no matter the value). Document this as a new general principle to be followed in the future. Affected modules:
    - 'mini.bufremove' (do nothing as recommended 'hidden' is on by default)
    - 'mini.completion' (conditionally set 'completeopt=menuone,noselect' and flags "c" in 'shortmess')
    - 'mini.statusline' (do nothing as recommended 'laststatus=2' is default)
    - 'mini.tabline' (unconditionally set 'showtabline=2', as it is essential to module's functinonality)

### Refine {#v0.16.0-all-refine}

- Soft deprecate support for Neovim 0.8. It will be fully stopped in next release.

## mini.ai {#v0.16.0-mini.ai}

### Refine {#v0.16.0-mini.ai-refine}

- Visual textobject selection now puts the cursor on the right edge instead of left. This better aligns with the (undocumented) behavior of how built-in `a` / `i` textobjects work in Visual mode, as opposed to the (documented in `:h operator-resulting-pos`) behavior of how it is done after applying the operator.

### Expand {#v0.16.0-mini.ai-expand}

- Textobject identifier can now be any single character supported by `:h getcharstr()`. This also makes it possible to use characters outside of Latin alphanumeric and punctuation sets as `custom_textobjects` keys. Default textobject is extended to be anything but Latin letters (to fall back to `:h text-objects`).

- Update `gen_spec.treesitter()` to respect capture ranges specified by query directives (like `(#offset! @table.inner 0 1 0 -1)`).

## mini.base16 {#v0.16.0-mini.base16}

### Refine {#v0.16.0-mini.base16-refine}

- Update 'mini.pick' highlight groups to show prompt text with same colors as match ranges, as they are connected.

### Expand {#v0.16.0-mini.base16-expand}

- Add support for colored markdown headings.

- Add new plugin integrations:
    - 'ibhagwan/fzf-lua'
    - 'MeanderingProgrammer/render-markdown.nvim'
    - 'OXY2DEV/helpview.nvim'
    - 'OXY2DEV/markview.nvim'

## mini.colors {#v0.16.0-mini.colors}

### Expand {#v0.16.0-mini.colors-expand}

- Update `convert()` to have `adjust_lightness` option which can be used to disable lightness adjustment (which is enabled by default for a more uniform progression from 0 to 100). This can be useful for output to be more consistent with other Oklab/Oklch implementations.

## mini.comment {#v0.16.0-mini.comment}

### Expand {#v0.16.0-mini.comment-expand}

- Update textobject to respect `ignore_blank_line` option. Blank lines between commented lines are treated as part of a textobject.

## mini.completion {#v0.16.0-mini.completion}

### Evolve {#v0.16.0-mini.completion-evolve}

- Add snippet support. By default uses 'mini.snippets' to manage snippet session (if enabled, **highly recommended), falls back to `vim.snippet` on Neovim>=0.10. See "Snippets" section in `:h MiniCompletion` for more details.

    This affect existing functionality because items with `Snippet` kind are no longer filtered out by default.

- Rework how LSP completion items are converted to Neovim's completion items:
    - Show `detail` highlighted as buffer's language at the start of info window, but only if `detail` provides information not already present in `documentation`. It was previously used as extra text in the popup menu (via `menu` field), but this doesn't quite follow LSP specification: `detail` and `documentation` fields can be delayed up until `completionItem/resolve` request which implies they should be treated similarly.
    - Show `labelDetails` as a part of the popup menu via `menu` completion item field.

- Rework how information window is shown with the goal to reduce flickering during fast up/down navigation through completion candidates:
    - Do not close the window immediately after the move. Instead highlight border with `MiniCompletionInfoBorderOutdated` immediately while update window when its content is ready. Close the window only if no candidate is selected.
    - Show content of already visited/resolved candidate without delay.
    - Show default `-No-info-` text if there is no extra information about the candidate.

- Update behavior and capabilities of `default_process_items()`:
    - Add `filtersort` option to control how items are filtered and/or sorted. Its new default value has changed behavior: do fuzzy matching if 'completeopt' option contains "fuzzy" entry; same as before otherwise.
    - Add `kind_priority` option to allow arranging items by completion item kind (like "Variable", "Snippet", "Text", etc.) after applying `filtersort`. This allows finer filter and/or sort based on kind, like "put Variable on top, Snippet on bottom, remove Text".
    - Use `filterText` and `label` item fields during matching (instead of `textEdit.newText`, `insertText`, and `label` as before). This is more aligned with LSP specification.

### Refine {#v0.16.0-mini.completion-refine}

- Prefer in some cases to use `nil` as default config value with explicit fallback. This should not have any user facing effects and marked as breaking only because a structure of a default config has changed. Affected fields:
    - `lsp_completion.process_items` (use `default_process_items` as fallback) and `fallback_action` (use `'<C-n>'` as fallback). This makes it more aligned with other modules that usually avoid using function values in default config.
    - `window.info.border` and `window.signature.border` (use non-empty 'winborder' and `'single'` as fallback).

- Change default value of `MiniCompletionActiveParameter` highlight group to link to `LspSignatureActiveParameter` (instead of forcing underline).

- Call `lsp_completion.process_items` with an array of items from all buffer servers at once (and not for each server separately). This can be used for more elaborate filter/sort strategies.

### Expand {#v0.16.0-mini.completion-expand}

- Add scrolling in info and signature window. By default can be done with `<C-f>` / `<C-b>` when target window is shown. Can be configured via `mappings.scroll_down` and `mappings.scroll_up` config options.

- Respect `isIncomplete` in LSP completion response and immediately force new completion request on the next key press.

- Add support for context in 'textDocument/completion' request.

- Both info and signature help windows now use tree-sitter highlighting:
    - Info window uses "markdown" parser (works best on Neovim>=0.10 as its parser is built-in). Special markdown characters are concealed (i.e. hidden) which might result into seemingly unnecessary whitespace as dimensions are computed not accounting for that.
    - Signature help uses same parser as in current filetype.

- Update signature help without delay if it is already shown. This helps to keep signature help up to date after cursor jumps in Insert mode (like during snippet session).

- Add support for item defaults in `CompletionList` response.

- Add `get_lsp_capabilities()` that returns data about which part of LSP specification is supported in 'mini.completion'.

- Input items for `lsp_completion.process_items` now have `client_id` field with the identifier of the server that item came from. Use `vim.lsp.get_client_by_id()` to get an actual data about the server.

## mini.diff {#v0.16.0-mini.diff}

### Expand {#v0.16.0-mini.diff-expand}

- The `config.source` can now be array of sources, which will be attempted to attach in order. Important for source's `attach` to either return `false` or call `MiniDiff.fail_attach()` (even not immediately) to signal that source has failed to attach to a particular buffer.

- Overlay virtual lines now scroll horizontally along with buffer lines. Requires Neovim>=0.11 and disabled 'wrap' option.

- Highlighting of buffer parts of change hunks can now be customized with these new highlight groups:
    - `MiniDiffOverChangeBuf` - changed buffer text. Previously used `MiniDiffOverChange` (for changed reference text); links to it by default.
    - `MiniDiffOverContextBuf` - context of a change shown in buffer overlay. Previously not highlighted, default highlight group is not created.

## mini.doc {#v0.16.0-mini.doc}

### Expand {#v0.16.0-mini.doc-expand}

- FEATURE: improve detection and formatting for types in `@param`, `@return`, and similar.

## mini.fuzzy {#v0.16.0-mini.fuzzy}

### Refine {#v0.16.0-mini.fuzzy-refine}

- Update `process_lsp_items()` to only use `filterText` and `label` item fields during fuzzy matching (instead of `textEdit.newText`, `insertText`, and `label` as before). This is more aligned with LSP specification.

- Treat empty `word` as matching any candidate (matched positions is empty array and score is -1). This behavior is usually more useful in practice.

## mini.hues {#v0.16.0-mini.hues}

### Evolve {#v0.16.0-mini.hues-evolve}

### Refine {#v0.16.0-mini.hues-refine}

- Update 'mini.pick' highlight groups to show prompt text with same colors as match ranges, as they are connected.

### Expand {#v0.16.0-mini.hues-expand}

- Add support for colored markdown headings.

- Add new plugin integrations:
    - 'ibhagwan/fzf-lua'
    - 'MeanderingProgrammer/render-markdown.nvim'
    - 'OXY2DEV/helpview.nvim'
    - 'OXY2DEV/markview.nvim'


## mini.keymap {#v0.16.0-mini.keymap}

### Expand {#v0.16.0-mini.keymap-expand}

- Introduction of a new module.

## mini.notify {#v0.16.0-mini.notify}

### Expand {#v0.16.0-mini.notify-expand}

- Add `lsp_progress.level` option to control level of LSP progress notifications.

- Add `MiniNotifyLspProgress` highlight group to be used for LSP progress notifications.

- Add `data` field to notification specification and as a new argument to `MiniNotify.add()`. It can be used to store any data relevant to the notification. For example, notifications from `make_notify()` output set `source` field to `'vim.notify'`, while notifications from LSP progress set `source` to `'lsp_progress'`.

## mini.operators {#v0.16.0-mini.operators}

### Expand {#v0.16.0-mini.operators-expand}

- Update `setup()` to remap built-in `gx` Normal/Visual mode mappings (for opening an URI under cursor) to `gX` (if that is not already taken).

## mini.pairs {#v0.16.0-mini.pairs}

### Expand {#v0.16.0-mini.pairs-expand}

- Update all actions to work with pairs containing multibyte characters (like "¿?", "「」", and similar).

## mini.pick {#v0.16.0-mini.pick}

### Refine {#v0.16.0-mini.pick-refine}

- Rename `prompt_cursor` in `config.window` to `prompt_caret` for better naming consistency. It works for now, but will stop in the next release. Sorry for the inconvenience.

### Expand {#v0.16.0-mini.pick-expand}

- Add `MiniPickPromptCaret` and `MiniPickPromptPrefix` highlight groups to allow finer customization of picker's prompt.

- Update `get_picker_matches()` to return data (items and indexes) about currently shown items.

- Update `set_picker_match_inds()` to be able to set current match and marked items indexes.

## mini.snippets {#v0.16.0-mini.snippets}

### Expand {#v0.16.0-mini.snippets-expand}

- Add `start_lsp_server()` to start specialized in-process LSP server to show loaded snippets inside (auto)completion engines (like 'mini.completion').

## mini.statusline {#v0.16.0-mini.statusline}

### Refine {#v0.16.0-mini.statusline-refine}

- Function `section_fileinfo()` got several updates:
    - File size is now computed based on the current buffer text and not for file's saved version.
    - File info is now shown even for buffers with empty 'filetype'. It previously was treated as a sign of a "temporary buffer", but it might be a result of an unsuccessful filetype matching.

## mini.surround {#v0.16.0-mini.surround}

### Expand {#v0.16.0-mini.surround-expand}

- Surrounding identifier can now be any single character supported by `:h getcharstr()`. This also makes it possible to use characters outside of Latin alphanumeric and punctuation sets as `custom_surroundings` keys.

- Update `gen_spec.input.treesitter()` to respect capture ranges specified by query directives (like `(#offset! @table.inner 0 1 0 -1)`).

## mini.tabline {#v0.16.0-mini.tabline}

### Expand {#v0.16.0-mini.tabline-expand}

- Add support for showing special (truncation) characters at left and/or right if there are more tabs to the left and/or right. They are shown with the new `MiniTablineTrunc` highlight group in case 'list' option is enabled (i.e. user deliberately enabled similar functionality for windows). Exact characters are taken from 'listchars' option: `precedes` and `extends` fields.

- Labels for quickfix and location lists are now different.


# Version 0.15.0 {#v0.15.0}

## mini.align {#v0.15.0-mini.align}

### Expand {#v0.15.0-mini.align-expand}

- Add built-in modifier for "|" character with aligning Markdown-like tables in mind.

## mini.animate {#v0.15.0-mini.animate}

### Evolve {#v0.15.0-mini.animate-evolve}

- Add `max_output_steps` option to `gen_path.line()` and `gen_path.angle()` to limit the number of steps the return. Default is 1000 to improve performance on large cursor jumps which also is set for `config.cursor.path`.

## mini.files {#v0.15.0-mini.files}

### Expand {#v0.15.0-mini.files-expand}

- Closing and refreshing explorer now requires confirmation only if there are pending file system actions (and not in case of at least one modified buffer present).

- Confirming file system actions in `synchronize()` now can cancel synchronization (by pressing `c`) while keeping buffer contents the same. `synchronize()` also returns a boolean representing whether synchronization was done.

## mini.git {#v0.15.0-mini.git}

### Expand {#v0.15.0-mini.git-expand}

- Git data is computed after resolving symlinks. This allows working with files symlinked into outside of Git repo. This behavior is the same as in 'mini.diff'.

## mini.hipatterns {#v0.15.0-mini.hipatterns}

### Refine {#v0.15.0-mini.hipatterns-refine}

- Make `MiniHipatterns{Fixme,Hack,Todo,Note}` highlight groups by default be reverse and bold variant of `Diagnostic{Error,Warn,Info,Hint}` group instead of directly link to them. This ensures better visibility for color schemes which don't have explicit 'mini.hipatterns' support.

## mini.hues {#v0.15.0-mini.hues}

### Expand {#v0.15.0-mini.hues-expand}

- Add `'lowmedium'` and `'mediumhigh'` saturation levels.

## mini.icons {#v0.15.0-mini.icons}

### Expand {#v0.15.0-mini.icons-expand}

- Add distinctive glyphs and highlighting for special Neovim directories (from `:h 'runtimepath'`).

## mini.indentscope {#v0.15.0-mini.indentscope}

### Evolve {#v0.15.0-mini.indentscope-evolve}

- Add `options.n_lines` option to limit the scope computation (for better performance). It's default value is 10000 while previous behavior behavior had no restriction (as with `n_lines = math.huge`) which should matter only in very big scopes.

- Add `draw.predicate` configuration to customize whether the scope should be autodrawn. It's default value does not draw scope with incomplete computation (i.e. interrupted due to `options.n_lines` value), which should matter only in very big scopes.

## mini.notify {#v0.15.0-mini.notify}

- FEATURE: `setup()` now also can be used to clean history (for example, like `MiniNotify.setup(MiniNotify.config)`).

## mini.pick {#v0.15.0-mini.pick}

### Evolve {#v0.15.0-mini.pick-evolve}

- Picker window now has local current directory set to source's `cwd`. This allows easier code for "in window" functions (callable items, choose, preview, etc.) as relative paths will be properly resolved. It also results in some changes:
    - Calling `set_picker_items_from_cli()` with active picker now resolves explicitly set to relative path `spawn_opts.cwd` against picker's `cwd` (and not against global current directory as was done previously).

### Expand {#v0.15.0-mini.pick-expand}

- Update `grep` and `grep_live` pickers to allow `globs` local option which restricts search to files that match any of its glob patterns (for example, `{ '*.lua', 'lua/**' }` will only search in Lua files and files in 'lua' directory). The `grep_live` picker also has custom `<C-o>` mapping to add globs interactively after picker is opened.

- Update `help` picker to have `default_split` local option which customizes split direction of `choose` action (`<CR>` by default).

- Update `ui_select()` to allow fourth argument `start_opts` to customize `MiniPick.start()` call.

- Add `MiniPickMatch` event triggered after updating query matches or setting items. Can be used, for example, to adjust window height based on current matches.

## mini.snippets {#v0.15.0-mini.snippets}

### Expand {#v0.15.0-mini.snippets-expand}

- Introduction of a new module.

## mini.surround {#v0.15.0-mini.surround}

### Refine {#v0.15.0-mini.surround-refine}

- Created mappings for `find`, `find_left`, and `highlight` are now *not* dot-repeatable. Dot-repeat should repeat last text change but neither of those actions change text. Having them dot-repeatable breaks the common "move cursor -> press dot" workflow. Initially making them dot-repeatable was a "you can but you should not" type of mistake.

## mini.test {#v0.15.0-mini.test}

### Evolve {#v0.15.0-mini.test-evolve}

- Now calling `skip()` in set's `pre_case` hook results in skipping all test cases in a set. Calling in other hooks has no effect. This enables a more structured skipping of all test cases inside a set. To skip inside hooks, use `add_note()` followed by `return`.

### Expand {#v0.15.0-mini.test-expand}

- Add `n_retry` test set property. When set, each case will be tried that at most that many times until first success (if any).

- Add `hooks.pre_source` and `hooks.post_source` fields to collected cases. They can be either `'once'` or `'case'` and allow a more granular control over case execution.

- Function `finally()` now can be called several times inside a single function with callbacks executed in order of how they were registered.

- Update `expect.reference_screenshot()` to allow `directory` option pointing to a directory where automatically constructed reference path is located.


# Version 0.14.0 {#v0.14.0}

## All {#v0.14.0-all}

### Evolve {#v0.14.0-all-evolve}

- Update help files to use code blocks with language annotation, as it results in a better code highlighting. Implies enabled tree-sitter highlighting in 'help' filetype:
    - It is default in Neovim>=0.10.
    - Tree-sitter parser is built-in in Neovim 0.9.x, needs manual enabling via `vim.treesitter.start()`.
    - Has visual regressions on Neovim 0.8.0 and 0.8.1 without enabled tree-sitter (code blocks are highlighted as normal text). Use 0.8.2 or newer.

- Universally prefer 'mini.icons' module over 'nvim-tree/nvim-web-devicons'.

### Refine {#v0.14.0-all-refine}

- Stop official support of Neovim 0.7.

### Expand {#v0.14.0-all-expand}

- Start automated testing on Windows and MacOS.

- Universally ensure that all plugin's highlight groups are defined after any color scheme takes effect.

## mini.base16 {#v0.14.0-mini.base16}

### Expand {#v0.14.0-mini.base16-expand}

- Add 'kevinhwang91/nvim-bqf' plugin integration.

## mini.completion {#v0.14.0-mini.completion}

### Expand {#v0.14.0-mini.completion-expand}

- Add highlighting of LSP kind (like "Function", "Keyword", etc.). Works only on Neovim>=0.11. Requires enabled 'mini.icons' to work out of the box.

## mini.doc {#v0.14.0-mini.doc}

### Evolve {#v0.14.0-mini.doc-evolve}

- Update `afterlines_to_code()` to result into Lua code block in help file by using `>lua` at the start instead of `>`. NOTE: users need enabled `help` tree-sitter parser (which is default on Neovim>=0.9) for code blocks to have proper highlighting.

## mini.extra {#v0.14.0-mini.extra}

### Refine {#v0.14.0-mini.extra-refine}

- Use "│" as line/position separator instead of ":". This aligns with changes in 'mini.pick' and makes line/position more easily visible.

### Expand {#v0.14.0-mini.extra-expand}

- Update `oldfiles` picker to have `current_dir` option which if `true` shows files only from picker's working directory. By @abeldekat, PR #997.

- Update `git_hunks`, `list`, and `lsp` pickers to show icons. Scopes `document_symbol` and `workspace_symbol` in `lsp` picker show icon based on LSP kind (requires set up 'mini.icons'), others - based on path data.

- Update `buf_lines` and `oldfiles` pickers to have `preserve_order` local option, similar to `visit_paths` picker. Other possible candidates for this option are intentionally not updated to not increase maintenance (manually override `match` source method to call `MiniPick.default_match()` with `{ preserve_order = true }` options).

- Update `buf_lines` picker to pad line numbers to achieve more aligned look.

## mini.git {#v0.14.0-mini.git}

### Expand {#v0.14.0-mini.git-expand}

- Update `show_at_cursor()` to include commit's statistics when showing commit.

- Update `show_at_cursor()` to show relevant at cursor commit data inside 'mini.deps' confirmation buffer.

## mini.hipatterns {#v0.14.0-mini.hipatterns}

### Evolve {#v0.14.0-mini.hipatterns-evolve}

- Update `compute_hex_color_group()` to compute based on combination of `hex_color` and `style`, opposed to just `hex_color`. This allows simultaneous usage of several styles in user's custom highlighters.

## mini.hues {#v0.14.0-mini.hues}

### Expand {#v0.14.0-mini.hues-expand}

- Implement `apply_palette()` (to compliment `make_palette()`) providing a way to tweak applied palette before applying it.

- Add 'kevinhwang91/nvim-bqf' plugin integration.

## mini.files {#v0.14.0-mini.files}

### Evolve {#v0.14.0-mini.files-evolve}

### Refine {#v0.14.0-mini.files-refine}

- Update how confirmation lines are computed:
    - Show create actions in the group directory where text manipulation took place. This matters during creating nested entries and is usually a more intuitive representation.
    - For delete show its type after the file name ("permanently" or "to trash") as an additional visual indication of delete type.
    - For create, copy and move prefer showing its "to" path relative to group directory.
    - Separate action name and paths with "│" (instead of ":") for better visual separation.
    - Don't enclose paths in quotes. Initially it was done to reliably show possible whitespace in paths, but inferring it from overall line structure should be good enough.

- Soft deprecate `get_target_window()` in favor of `get_explorer_state().target_window`. Will be completely removed after the next release.

### Expand {#v0.14.0-mini.files-expand}

- Prefer using 'mini.icons' as icon provider.

- Implement bookmarks. With default config:
    - Type `m` followed by a single character `<char>` to set directory path of focused window as a bookmark with id `<char>`.
    - Type `'` followed by a bookmark id to make bookmark's path focused in explorer.
    - Use `MiniFiles.set_bookmark()` inside `MiniFilesExplorerOpen` event to set custom bookmarks.

- Make data for `MiniFilesActionDelete` contain `to` field in case of not permanent delete.

- Make file manipulation work better for special complex/overlapping cases (like delete 'file-a' and copy 'file-b' as 'file-a'). It is **still** a better idea to split overlapping manipulations into smaller and not related steps, as there *are* cases which won't work.

- Add `get_explorer_state()` to allow more reliable user customizations.

- Add `set_branch()` to allow to set what paths should be displayed and focused.

## mini.icons {#v0.14.0-mini.icons}

### Expand {#v0.14.0-mini.icons-expand}

- Introduction of a new module.

## mini.misc {#v0.14.0-mini.misc}

### Expand {#v0.14.0-mini.misc-expand}

- Implement `setup_termbg_sync()` to set up terminal background synchronization (removes possible "frame" around current Neovim instance). Works only on Neovim>=0.10.

## mini.pick {#v0.14.0-mini.pick}

### Evolve {#v0.14.0-mini.pick-evolve}

### Refine {#v0.14.0-mini.pick-refine}

- Update `default_match()` to have table `opts` as fourth argument (instead of boolean `do_sync`). Use `{ sync = true }` to run synchronously. The new design is more aligned with other functions and is more forward compatible.

- Encoding line or position in string items has changed:
    - Use "\0" (null character; use "\000" form if it is in a string before digit) instead of ":" as delimiter. This makes it work with files similar to ":" position encoding (like "time_12:34:56"). This only matters for custom sources which provide line or position in string items.
    - Update `default_show()` to display "│" character instead of "\0" in item's string representation (previously was ":"). In particular, this changes how line/position is displayed in `grep` and `grep_live` built-in pickers. This change was done because "│" is more visible as separator.

### Expand {#v0.14.0-mini.pick-expand}

- Prefer using 'mini.icons' as icon provider.

- Add `preserve_order` option to `default_match()` to allow asynchronous matching which preserves order (i.e. doesn't do sort step of fuzzy matching).

- Explicitly hide cursor when picker is active (instead of putting it in command line).

## mini.starter {#v0.14.0-mini.starter}

### Refine {#v0.14.0-mini.starter-refine}

- Change filetype of Starter buffer from 'starter' to 'ministarter'. This is a more robust value and more aligned with other modules.

## mini.statusline {#v0.14.0-mini.statusline}

### Refine {#v0.14.0-mini.statusline-refine}

- Update `section_fileinfo()` to show non-empty filetype even in not normal buffers (like plugin's scratch buffers, help, quickfix, etc.). Previously it showed nothing, which was a mistake as filetype can be a valuable information.

- The default `set_vim_settings` config value now does not affect `laststatus = 3` (aka global statusline).

### Expand {#v0.14.0-mini.statusline-expand}

- Prefer using 'mini.icons' as icon provider for `section_fileinfo()`.

## mini.surround {#v0.14.0-mini.surround}

### Refine {#v0.14.0-mini.surround-refine}

- Adding surrounding in linewise mode now also ignores trailing whitespace on the last line (same as it ignores indent on the first line).

## mini.tabline {#v0.14.0-mini.tabline}

### Expand {#v0.14.0-mini.tabline-expand}

- Prefer using 'mini.icons' as icon provider.

## mini.test {#v0.14.0-mini.test}

### Expand {#v0.14.0-mini.test-expand}

- Make it work on Windows. By @cameronr, PR #1101.


# Version 0.13.0 {#v0.13.0}

## mini.comment {#v0.13.0-mini.comment}

### Refine {#v0.13.0-mini.comment-refine}

- Blank lines are now completely ignored when deciding the toggling action. In practice this means that if target block consists only from commented and/or blank lines, it will be uncommented rather than commented.

- Whitespace in comment parts is now treated more explicitly. In particular:
    - Default `options.pad_comment_parts = true` now more explicitly means that any value of 'commentstring' is transformed so that comment parts have exactly single space inner padding.

      Example: any `/*%s*/`, ` /* %s */ `, or `/*  %s  */` is equivalent to having `/* %s */`.

    - Detection of whether consecutive lines are commented or not does not depend on whitespace in comment parts. Uncommenting is first attempted with exact comment parts and falls back on trying its trimmed parts.

      Example of toggling comment on single line with `/* %s */` 'commentstring' value:
        - `/* this is commented */` -> `this is commented`.
        - `/*this is also commented */` -> `this is also commented ` (notice trailing space).

    - Commenting blank lines is done with trimmed comments parts, while uncommenting explicitly results into empty lines.

### Expand {#v0.13.0-mini.comment-expand}

- Support dot-repeat after initial commenting is done for visual selection; repeating is done for same relative range.

## mini.deps {#v0.13.0-mini.deps}

### Expand {#v0.13.0-mini.deps-expand}

- Add `MiniDepsMsgBreaking` highlight group for messages indicating a breaking change in a conventional commit style.

## mini.diff {#v0.13.0-mini.diff}

### Expand {#v0.13.0-mini.diff-expand}

- Introduction of a new module.

## mini.files {#v0.13.0-mini.files}

### Expand {#v0.13.0-mini.files-expand}

- Add new `MiniFilesExplorerOpen` and `MiniFilesExplorerClose` events.

## mini.git {#v0.13.0-mini.git}

### Expand {#v0.13.0-mini.git-expand}

- Introduction of a new module.

## mini.hues {#v0.13.0-mini.hues}

### Refine {#v0.13.0-mini.hues-refine}

- Update some highlight groups for better usability:
    - `DiffChange` and `DiffText` - make changed diff lines have colored background.
    - `Folded` - make folds differ from `CursorLine`.
    - `QuickFixLine` - make current quickfix item differ from `CursorLine`.

## mini.map {#v0.13.0-mini.map}

### Expand {#v0.13.0-mini.map-expand}

- Add `gen_integration.diff()` which highlights general diff hunks from 'mini.diff'.

## mini.pick {#v0.13.0-mini.pick}

### Evolve {#v0.13.0-mini.pick-evolve}

### Refine {#v0.13.0-mini.pick-refine}

- Stop trying to parse path for special format ("path:row" and "path:row:col") if supplied inside a table item. This made impossible working with paths containing ":".

- Update `builtin.files()` to use table items when string item might be ambiguous.

### Expand {#v0.13.0-mini.pick-expand}

- Respect general URI format for paths inside table items.

## mini.starter {#v0.13.0-mini.starter}

### Refine {#v0.13.0-mini.starter-refine}

- Explicitly block all events in `open()` during startup for a better performance.

## mini.statusline {#v0.13.0-mini.statusline}

### Evolve {#v0.13.0-mini.statusline-evolve}

- Update `section_git()` to prefer using data from 'mini.git' with fallback on pure HEAD data from 'lewis6991/gistigns.nvim'.

- Update default active content:
    - Add `section_diff()` (shows diff data near  icon) following refactor of `section_git()`.
    - Add `section_lsp()` (shows number of attached LSP servers near 󰰎 icon) following refactor of `section_diagnostics()`.

### Refine {#v0.13.0-mini.statusline-refine}

- Update `section_diagnostics()` to depend only on defined diagnostic. This means:
    - Something is shown **only** if there is any diagnostic actually present in the buffer. No diagnostic entries - nothing is shown. Previously it did not show if there was no LSP servers attached (as initially diagnostics came only from LSP) or buffer was not normal.
    - Fallback icon is "Diag" instead of "LSP".

### Expand {#v0.13.0-mini.statusline-expand}

- Update `section_diagnostics()` to support `signs` table option to customize signs for severity levels.

- Add `section_diff()` to show data from 'mini.diff' with fallback on diff data from 'lewis6991/gistigns.nvim'.

- Add `section_lsp()` to show indicator of LSP servers attached to the buffer.

## mini.tabline {#v0.13.0-mini.tabline}

### Expand {#v0.13.0-mini.tabline-expand}

- Implement `config.format` for custom label formatting.

## mini.test {#v0.13.0-mini.test}

### Refine {#v0.13.0-mini.test-refine}

- Child process is now created with extra `--headless --cmd "set lines=24 columns=80"` arguments making it headless but still reasonably similar to fully functioning Neovim during interactive usage. This change should generally not break a lot of things, while enabling a faster and more robust test execution.


# Version 0.12.0 {#v0.12.0}

## mini.basics {#v0.12.0-mini.basics}

### Refine {#v0.12.0-mini.basics-refine}

- Remove `<C-z>` mapping, as it is more useful in most terminal emulators for suspending Neovim process (to later resume with `fg` command). To correct latest misspelled word, use mappings like this:

    ```lua
    vim.keymap.set('n', '<C-z>', '[s1z=',                     { desc = 'Correct latest misspelled word' })
    vim.keymap.set('i', '<C-z>', '<C-g>u<Esc>[s1z=`]a<C-g>u', { desc = 'Correct latest misspelled word' })
    ```

### Expand {#v0.12.0-mini.basics-expand}

- Add `tab:> ` to 'listchars' option when `options.extra_ui` is set. This prevents showing `^I` instead of a tab and actual value comes from Neovim's default.

- Set `termguicolors` only on Neovim<0.10, as later versions should have it on by default (if terminal emulator supports it).

## mini.comment {#v0.12.0-mini.comment}

### Expand {#v0.12.0-mini.comment-expand}

- Hooks are now called with data about commenting action.

## mini.deps {#v0.12.0-mini.deps}

### Expand {#v0.12.0-mini.deps-expand}

- Introduction of a new module.

## mini.doc {#v0.12.0-mini.doc}

### Refine {#v0.12.0-mini.doc-refine}

- Stop using `:echo` to display messages and warnings in favor of `vim.notify()`.

- Update default `write_post` hook to not display current time in success message.

- Update to include space before `~` in generated section headings.

## mini.files {#v0.12.0-mini.files}

### Expand {#v0.12.0-mini.files-expand}

- Update `go_in()` to have `close_on_file` option.

- Show warning if action is set to override existing path.

## mini.hues {#v0.12.0-mini.hues}

### Refine {#v0.12.0-mini.hues-refine}

- Update verbatim text (`@text.literal` and `@markup.raw`) color to be distinctive instead of dimmed.

### Expand {#v0.12.0-mini.hues-expand}

- Add support for new standard tree-sitter captures on Neovim>=0.10 (see https://github.com/neovim/neovim/pull/27067).

## mini.misc {#v0.12.0-mini.misc}

### Refine {#v0.12.0-mini.misc-refine}

- Update `bench_time()` to use `vim.loop.hrtime()` (as better designed for benchmarking) instead of `vim.loop.gettimeofday()`.

## mini.notify {#v0.12.0-mini.notify}

### Expand {#v0.12.0-mini.notify-expand}

- Introduction of a new module.

## mini.pick {#v0.12.0-mini.pick}

### Expand {#v0.12.0-mini.pick-expand}

- Implement `window.prompt_cursor` and `window.prompt_prefix` config options.

- Update `builtin.help()` to use tree-sitter highlighting (if there is any).

## mini.sessions {#v0.12.0-mini.sessions}

### Refine {#v0.12.0-mini.sessions-refine}

- Update `read()` to first `write()` current session (if there is any).

## mini.starter {#v0.12.0-mini.starter}

### Expand {#v0.12.0-mini.starter-expand}

- Add `sections.pick()` with 'mini.pick' pickers.

## mini.statusline {#v0.12.0-mini.statusline}

### Evolve {#v0.12.0-mini.statusline-evolve}

- Add `search_count` section to default active content.

## mini.visits {#v0.12.0-mini.visits}

### Expand {#v0.12.0-mini.visits-expand}

- Introduction of a new module.


# Version 0.11.0 {#v0.11.0}

## mini.base16 {#v0.11.0-mini.base16}

### Refine {#v0.11.0-mini.base16-refine}

- Stop supporting deprecated 'HiPhish/nvim-ts-rainbow2'.

## mini.bufremove {#v0.11.0-mini.bufremove}

### Evolve {#v0.11.0-mini.bufremove-evolve}

- Applying `delete()` and `wipeout()` without `force` in a modified buffer now asks for confirmation instead of declining and showing message.

## mini.clue {#v0.11.0-mini.clue}

### Expand {#v0.11.0-mini.clue-expand}

- Value of `config.window.config` now can be callable returning window config.

## mini.comment {#v0.11.0-mini.comment}

### Expand {#v0.11.0-mini.comment-expand}

- Implement `config.mappings.comment_visual` to configure mapped keys in Visual mode.

## mini.completion {#v0.11.0-mini.completion}

### Evolve {#v0.11.0-mini.completion-evolve}

- Start adding `C` flag to `shortmess` option on Neovim>=0.9. By @yamin-shihab, PR #554.

## mini.extra {#v0.11.0-mini.extra}

### Expand {#v0.11.0-mini.extra-expand}

- Introduction of a new module.

## mini.files {#v0.11.0-mini.files}

### Refine {#v0.11.0-mini.files-refine}

- Opening file which is present in unlisted buffer now makes the buffer listed.

- Highlight in preview now is not enabled if file is sufficiently large.

### Expand {#v0.11.0-mini.files-expand}

- Explorer now tracks if focus is lost and properly closes on detection.

- Implement `MiniFilesCursorLine` highlight group.

## mini.hipatterns {#v0.11.0-mini.hipatterns}

### Refine {#v0.11.0-mini.hipatterns-refine}

- Field `priority` in highlighter definitions is soft deprecated in favor of `extmark_opts = { priority = <value> }`.

### Expand {#v0.11.0-mini.hipatterns-expand}

- Allow `pattern` in highlighter definitions to be an array to highlight several patterns under the same highlighter name.

- Implement `extmark_opts` in highlighter definitions for a more control over extmarks placed at matches.

- Update `compute_hex_color_group()` to allow `style = 'fg'`.

- Update `gen_highlighter.hex_color()` to allow `style = 'inline'` (requires Neovim>=0.10 with support of inline extmarks).

- Implement `get_matches()` to get buffer matches.

## mini.hues {#v0.11.0-mini.hues}

### Refine {#v0.11.0-mini.hues-refine}

- Stop supporting deprecated 'HiPhish/nvim-ts-rainbow2'.

## mini.map {#v0.11.0-mini.map}

### Expand {#v0.11.0-mini.map-expand}

- Implement `config.window.zindex` to configure z-index of map window.

## mini.misc {#v0.11.0-mini.misc}

### Expand {#v0.11.0-mini.misc-expand}

- Update `setup_auto_root()` and `find_root()` to now have `fallback` argument to be applied when no root is found with `vim.fn.find()`.

## mini.pick {#v0.11.0-mini.pick}

### Expand {#v0.11.0-mini.pick-expand}

- Introduction of a new module.

## mini.starter {#v0.11.0-mini.starter}

### Expand {#v0.11.0-mini.starter-expand}

- Value of `show_path` in `sections.recent_files()` can now be callable for more control on how full path is displayed.

## mini.test {#v0.11.0-mini.test}

### Evolve {#v0.11.0-mini.test-evolve}

- Update `child.get_screenshot()` to now by default call `:redraw` prior to computing screenshot. Can be disabled by new `opts.redraw` argument.

### Refine {#v0.11.0-mini.test-refine}

- Error in any "pre" hook now leads to test case not being executed (with note).

### Expand {#v0.11.0-mini.test-expand}

- New method `child.lua_func()` can execute simple functions inside child process and return the result (stasjok, #437).

- Update `expect.reference_screenshot()` to now have `ignore_lines` option allowing to ignore specified lines during screenshot compare.


# Version 0.10.0 {#v0.10.0}

## mini.ai {#v0.10.0-mini.ai}

### Expand {#v0.10.0-mini.ai-expand}

- Allow `vis_mode` field in custom texobject region to force Visual mode with which textobject is selected.

## mini.animate {#v0.10.0-mini.animate}

### Expand {#v0.10.0-mini.animate-expand}

- Add `MiniAnimateNormalFloat` highlight group to tweak highlighting of `open` and `close` animations.

## mini.base16 {#v0.10.0-mini.base16}

### Expand {#v0.10.0-mini.base16-expand}

- Add 'HiPhish/rainbow-delimiters.nvim' integration.

## mini.basics {#v0.10.0-mini.basics}

### Refine {#v0.10.0-mini.basics-refine}

- Remove `<C-w>` mapping in Terminal mode, as it is more useful inside terminal emulator itself.

## mini.bracketed {#v0.10.0-mini.bracketed}

### Expand {#v0.10.0-mini.bracketed-expand}

- Add `add_to_jumplist` option to relevant targets (which move cursor and don't already add to jumplist).

## mini.bufremove {#v0.10.0-mini.bufremove}

### Refine {#v0.10.0-mini.bufremove-refine}

- Create normal buffer instead of scratch when there is no reasonable target to focus (#394).

## mini.clue {#v0.10.0-mini.clue}

### Expand {#v0.10.0-mini.clue-expand}

- Introduction of a new module.

## mini.files {#v0.10.0-mini.files}

### Expand {#v0.10.0-mini.files-expand}

- Introduction of a new module.

## mini.hues {#v0.10.0-mini.hues}

### Expand {#v0.10.0-mini.hues-expand}

- Add 'HiPhish/rainbow-delimiters.nvim' integration.

## mini.jump2d {#v0.10.0-mini.jump2d}

### Expand {#v0.10.0-mini.jump2d-expand}

- Add `gen_union_spotter()` to allow combining separate spotters into one.

## mini.operators {#v0.10.0-mini.operators}

### Expand {#v0.10.0-mini.operators-expand}

- Introduction of a new module.

## mini.pairs {#v0.10.0-mini.pairs}

### Expand {#v0.10.0-mini.pairs-expand}

- Allow `false` in `config.mappings` to not map the key.

## mini.surround {#v0.10.0-mini.surround}

### Expand {#v0.10.0-mini.surround-expand}

- Update `add` (`sa`) with ability to replicate left and right parts by respecting `[count]`. In Normal mode two kinds of `[count]` is respected: one for operator (replicates left and right parts) and one for textobject/motion. In Visual mode `[count]` replicates parts.


# Version 0.9.0 {#v0.9.0}

## All {#v0.9.0-all}

### Evolve {#v0.9.0-all-evolve}

- Use Lua API to create autocommands. Stop exporting functions only related to autocommands.

- Use `vim.keymap` to deal with mappings. Stop exporting functions only related to mappings.

### Refine {#v0.9.0-all-refine}

- Stop official support of Neovim 0.6.

### Expand {#v0.9.0-all-expand}

- Add 'randomhue' color scheme.

## mini.base16 {#v0.9.0-mini.base16}

### Evolve {#v0.9.0-mini.base16-evolve}

- Stop supporting archived 'p00f/nvim-ts-rainbow' in favor of 'HiPhish/nvim-ts-rainbow2'.

### Expand {#v0.9.0-mini.base16-expand}

- Add new integrations:
    - Lsp semantic tokens.
    - 'folke/lazy.nvim'.
    - 'folke/noice.nvim'.
    - 'kevinhwang91/nvim-ufo'.

## mini.basics {#v0.9.0-mini.basics}

### Expand {#v0.9.0-mini.basics-expand}

- Add dot-repeat support for adding empty lines (`go` and `gO` mappings).

## mini.colors {#v0.9.0-mini.colors}

### Expand {#v0.9.0-mini.colors-expand}

- Introduction of a new module.

## mini.comment {#v0.9.0-mini.comment}

### Expand {#v0.9.0-mini.comment-expand}

- Use tree-sitter information about locally active language to infer 'commentstring' option value.

- Add `options.custom_commentstring` option for a more granular customization of comment structure.

- Add `get_commentstring()` function representing built-in logic of computing relevant 'commentstring'.

## mini.hipatterns {#v0.9.0-mini.hipatterns}

### Expand {#v0.9.0-mini.hipatterns-expand}

- Introduction of a new module.

## mini.hues {#v0.9.0-mini.hues}

### Expand {#v0.9.0-mini.hues-expand}

- Introduction of a new module.


# Version 0.8.0 {#v0.8.0}

## All {#v0.8.0-all}

### Expand {#v0.8.0-all-expand}

- Add and implement design principle for silencing module by setting `config.silent = true`. It is now present in modules capable of showing non-error feedback:
    - mini.ai
    - mini.align
    - mini.basics
    - mini.bufremove
    - mini.doc
    - mini.jump
    - mini.jump2d
    - mini.starter
    - mini.surround
    - mini.test

## mini.bracketed {#v0.8.0-mini.bracketed}

### Expand {#v0.8.0-mini.bracketed-expand}

- Introduction of a new module.

## mini.comment {#v0.8.0-mini.comment}

### Expand {#v0.8.0-mini.comment-expand}

- Add `options.start_of_line` option which controls whether to recognize as comment only lines without indent.

- Add `options.ignore_blank_line` option which controls whether to ignore blank lines.

- Add `options.pad_comment_parts` option which controls whether to ensure single space pad for comment leaders.

## mini.doc {#v0.8.0-mini.doc}

### Expand {#v0.8.0-mini.doc-expand}

- Add `config.hooks.write_pre` hook to be executed before writing to a file.

## mini.indentscope {#v0.8.0-mini.indentscope}

### Expand {#v0.8.0-mini.indentscope-expand}

- Add `MiniIndentscopeSymbolOff` highlight group to be used if scope's indent is not multiple of 'shiftwidth'.

- Add `draw.priority` option to control priority of scope line draw.

## mini.jump2d {#v0.8.0-mini.jump2d}

### Expand {#v0.8.0-mini.jump2d-expand}

- Add `view.n_steps_ahead` option which controls how many steps ahead to show. Appearance is controlled by new `MiniJump2dSpotAhead` highlight group.

- Add `view.dim` option which controls whether to dim lines with at least one jump spot. Appearance is controlled by new `MiniJump2dDim` highlight group.

- Add `MiniJump2dSpotUnique` highlight group to be used for spots with unique label for next step.

## mini.pairs {#v0.8.0-mini.pairs}

### Expand {#v0.8.0-mini.pairs-expand}

- Both `MiniPairs.br()` and `MiniPairs.cr()` can now take a key which will be used instead of default `<BS>` and `<CR>`.

## mini.sessions {#v0.8.0-mini.sessions}

### Expand {#v0.8.0-mini.sessions-expand}

- Update `setup()` to now create global directory at path `config.directory` if it doesn't exist.

- All actions now keep list of detected sessions up to date.

## mini.splitjoin {#v0.8.0-mini.splitjoin}

### Expand {#v0.8.0-mini.splitjoin-expand}

- Introduction of a new module.

## mini.surround {#v0.8.0-mini.surround}

### Expand {#v0.8.0-mini.surround-expand}

- Add `respect_selection_type` option which, when enabled, makes adding and deleting surrounding respect selection type:
    - Linewise adding places surrounding parts on separate lines while indenting surrounded lines once.
    - Deleting surrounding which looks like a result of linewise adding will act to revert it: delete lines with surrounding parts and dedent surrounded lines once.
    - Blockwise adding places surrounding parts on whole edges, not only start and end of selection.


# Version 0.7.0 {#v0.7.0}

## All {#v0.7.0-all}

### Expand {#v0.7.0-all-expand}

- Start dual distribution. Every module is now distributed both as part of 'mini.nvim' library and as standalone plugin (in separate git repository).

## mini.ai {#v0.7.0-mini.ai}

### Refine {#v0.7.0-mini.ai-refine}

- In `MiniAi.gen_spec.argument()` option `separators` (plural; array of characters) is soft deprecated in favor of `separator` (singular; Lua pattern) option.

## mini.animate {#v0.7.0-mini.animate}

### Expand {#v0.7.0-mini.animate-expand}

- Introduction of a new module.

## mini.basics {#v0.7.0-mini.basics}

### Expand {#v0.7.0-mini.basics-expand}

- Introduction of a new module.

## mini.completion {#v0.7.0-mini.completion}

### Refine {#v0.7.0-mini.completion-refine}

- Rename `MiniCompletion.config.window_dimensions` to `MiniCompletion.config.window` to be able to handle more general configuration.

### Expand {#v0.7.0-mini.completion-expand}

- Add `MiniCompletion.config.window.info.border` and `MiniCompletion.config.window.signature.border` which can be used to define border of info and signature floating windows respectively.

## mini.indentscope {#v0.7.0-mini.indentscope}

### Refine {#v0.7.0-mini.indentscope-refine}

- Stop using (deprecate) `MiniIndentscopePrefix` highlight groups. It was initially introduced as a way to properly show scope indicator on empty lines. It had a drawback of overshadowing 'listchars' symbols (see #125) and vertical guides from 'lukas-reineke/indent-blankline.nvim'. As the other implementation approach was found by @mivort (see #161), `MiniIndentscopePrefix` is no longer needed and no overshadowing is done.

- Update `MiniIndentscope.gen_animation` to now be a table (for consistency with other `gen_*` functions in 'mini.nvim'). See "Migrate from function type" section of `:h MiniIndentscope.gen_animation`. Calling it as function will be available until next release.

## mini.misc {#v0.7.0-mini.misc}

### Expand {#v0.7.0-mini.misc-expand}

- Add `MiniMisc.setup_auto_root()` and `MiniMisc.find_root()` for root finding functionality. NOTE: requires Neovim>=0.8.

- Add `MiniMisc.setup_restore_cursor()` for automatically restoring latest cursor position on file reopen. By @cryptomilk, PR #198.

## mini.move {#v0.7.0-mini.move}

### Expand {#v0.7.0-mini.move-expand}

- Introduction of a new module.


# Version 0.6.0 {#v0.6.0}

## All {#v0.6.0-all}

### Refine {#v0.6.0-all-refine}

- Stop official support of Neovim 0.5.

### Expand {#v0.6.0-all-expand}

- Make all messages use colors and not cause hit-enter-prompt.

## mini.align {#v0.6.0-mini.align}

### Expand {#v0.6.0-mini.align-expand}

- Introduction of a new module.

## mini.base16 {#v0.6.0-mini.base16}

### Refine {#v0.6.0-mini.base16-refine}

- Change some 'mini.nvim' highlights:
    - `MiniCompletionActiveParameter` now highlights with background instead of underline.
    - `MiniJump2dSpot` now explicitly defined to use plugin's palette.
    - `MiniStarterItemPrefix` and `MiniStarterQuery` are now bold for better visibility.

- Update highlight for changed git diff to be more visible and to comply more with general guidelines.

### Expand {#v0.6.0-mini.base16-expand}

- Add support for many plugin integrations.

- Implement `MiniBase16.config.plugins` for configuring plugin integrations.

## mini.jump {#v0.6.0-mini.jump}

### Refine {#v0.6.0-mini.jump-refine}

- Allow cursor to be positioned past the end of previous/current line (#113).

## mini.map {#v0.6.0-mini.map}

### Expand {#v0.6.0-mini.map-expand}

- Introduction of a new module.

## mini.starter {#v0.6.0-mini.starter}

### Refine {#v0.6.0-mini.starter-refine}

- Item evaluation is now prepended with query reset, as it is rarely needed any more (#105).

- All hooks are now called with `(content, buf_id)` signature allowing them properly use current window layout.

## mini.surround {#v0.6.0-mini.surround}

### Evolve {#v0.6.0-mini.surround-evolve}

- Update 'mini.surround' to share as much with 'mini.ai' as possible. This provides more integrated experience while enabling more useful features. Details:
    - Custom surrounding specification for input action has changed. Instead of `{ find = <string>, extract = <string> }` it is now `{ <function or composed pattern> }`. Previous format will work until the next release. See more in help file.
    - Algorithm for finding surrounding is now more powerful. It allows searching for more complex surroundings (via composed patterns or array of region pairs) and respects `v:count`.
    - Multiline input and output surroundings are now supported.
    - Opening brackets (`(`, `[`, `{`, `<`) now include whitespace in surrounding: input surrounding selects all inner edge whitespace, output surrounding is padded with single space.
    - Surrounding identifier `i` ("interactive") is soft deprecated in favor of `?` ("user prompt").
    - New surrounding aliases:
        - `b` for "brackets". Input - any of balanced `()`, `[]` `{}`. Output - `()`.
        - `q` for "quotes". Input - any of `"`, `'`, `` ` ``. Output - `""`.
    - Three new search methods `'prev'`, `'next'`, and `'nearest'` for finding non-covering previous and next surrounding.

- Implement "last"/"next" extended mappings which force `'prev'` or `'next'` search method. Controlled with `config.mappings.suffix_last` and `config.mappings.suffix_next`respectively. This also means that custom surroundings with identifier equal to "last"/"next" mappings suffixes (defaults to 'l' and 'n') will work only with long enough delay after typing action mapping.

### Expand {#v0.6.0-mini.surround-expand}

- Implement `MiniSurround.gen_spec` with generators of common surrounding specifications (like `MiniSurround.gen_spec.input.treesitter` for tree-sitter based input surrounding).


# Version 0.5.0 {#v0.5.0}

## All {#v0.5.0-all}

### Refine {#v0.5.0-all-refine}

- Update all tests to use new 'mini.test' module.

### Expand {#v0.5.0-all-expand}

- Implement buffer local configuration. This is done with `vim.b.mini*_config` buffer variables.

- Add new `minicyan` color scheme.

## mini.ai {#v0.5.0-mini.ai}

- Introduction of a new module.

## mini.comment {#v0.5.0-mini.comment}

### Expand {#v0.5.0-mini.comment-expand}

- Now hooks can be used to terminate further actions by returning `false` (#108).

## mini.indentscope {#v0.5.0-mini.indentscope}

### Refine {#v0.5.0-mini.indentscope-refine}

- Soft deprecate `vim.b.miniindentscope_options` in favor of using `options` field of `miniindentscope_config`.

## mini.sessions {#v0.5.0-mini.sessions}

### Expand {#v0.5.0-mini.sessions-expand}

- Hooks are now called with active session data as argument.

## mini.starter {#v0.5.0-mini.starter}

### Evolve {#v0.5.0-mini.starter-evolve}

### Refine {#v0.5.0-mini.starter-refine}

- Deprecate `MiniStarter.content` in favor of `MiniStarter.get_content()`.

### Expand {#v0.5.0-mini.starter-expand}

- Make it possible to open multiple Starter buffers at the same time (#82).

- All functions dealing with Starter buffer now have `buf_id` as argument.

## mini.statusline {#v0.5.0-mini.statusline}

### Expand {#v0.5.0-mini.statusline-expand}

- Implement `config.use_icons` which controls whether to use icons by default.

## mini.test {#v0.5.0-mini.test}

- Introduction of a new module.

## mini.trailspace {#v0.5.0-mini.trailspace}

### Expand {#v0.5.0-mini.trailspace-expand}

- Implement `MiniTrailspace.trim_last_lines()`.


# Version 0.4.0 {#v0.4.0}

## All {#v0.4.0-all}

### Expand {#v0.4.0-all-expand}

- Update all modules to supply mapping description for Neovim>=0.7.

- Cover all modules with extensive tests.

## mini.comment {#v0.4.0-mini.comment}

### Expand {#v0.4.0-mini.comment-expand}

- Implement `config.hooks` with `pre` and `post` hooks (executed before and after successful commenting). Fixes #50, #59.

## mini.completion {#v0.4.0-mini.completion}

### Expand {#v0.4.0-mini.completion-expand}

- Implement support for `additionalTextEdits` (issue #61).

## mini.jump {#v0.4.0-mini.jump}

### Refine {#v0.4.0-mini.jump-refine}

- Soft deprecate `config.highlight_delay` in favor of `config.delay.highlight`.

### Expand {#v0.4.0-mini.jump-expand}

- Implement idle timeout to stop jumping automatically (@annenpolka, #56).

- Implement `MiniJump.state`: table with useful model-related information.

- Update process of querying target symbol: show help message after delay, allow `<C-c>` to stop selecting target.

## mini.jump2d {#v0.4.0-mini.jump2d}

- Introduction of a new module.

## mini.pairs {#v0.4.0-mini.pairs}

### Refine {#v0.4.0-mini.pairs-refine}

- Create mappings for `<BS>` and `<CR>` in certain mode only after some pair is registered in that mode.

## mini.sessions {#v0.4.0-mini.sessions}

### Refine {#v0.4.0-mini.sessions-refine}

- All feedback about incorrect behavior is now an error instead of message notifications.

### Expand {#v0.4.0-mini.sessions-expand}

- Implement `MiniSessions.select()` to select session interactively and perform action on it.

- Implement `config.hooks` to execute hook functions before and after successful action.

## mini.starter {#v0.4.0-mini.starter}

### Expand {#v0.4.0-mini.starter-expand}

- Allow `config.header` and `config.footer` be any value, which will be converted to string via `tostring()`.

- Update query logic to not allow queries which result into no items.

- Add `<C-n>` and `<C-p>` to default mappings.

## mini.statusline {#v0.4.0-mini.statusline}

### Refine {#v0.4.0-mini.statusline-refine}

- Change default icon for `MiniStatusline.section_diagnostics()` from ﯭ to  due to former having issues in some terminal emulators.

## mini.surround {#v0.4.0-mini.surround}

### Evolve {#v0.4.0-mini.surround-evolve}

### Refine {#v0.4.0-mini.surround-refine}

- Deprecate `config.funname_pattern` option in favor of manually modifying `f` surrounding.

- Always move cursor to the right of left surrounding in `add()`, `delete()`, and `replace()` (instead of moving only if it was on the same line as left surrounding).

### Expand {#v0.4.0-mini.surround-expand}

- Implement `config.search_method`.

- Implement custom surroundings via `config.custom_surroundings`.

- Implement `MiniSurround.user_input()`.

- Update process of getting user input: allow `<C-c>` to cancel and make empty string a valid input.

## mini.tabline {#v0.4.0-mini.tabline}

### Refine {#v0.4.0-mini.tabline-refine}

- Show listed buffers also in case of multiple tabpages (instead of using builtin behavior).

### Expand {#v0.4.0-mini.tabline-expand}

- Implement `config.tabpage_section`.

- Show quickfix/loclist buffers with special `*quickfix*` label.


# Version 0.3.0 {#v0.3.0}

## All {#v0.3.0-all}

### Expand {#v0.3.0-all-expand}

- Update all modules to have annotations formatted for 'mini.doc'.

## mini.cursorword {#v0.3.0-mini.cursorword}

### Expand {#v0.3.0-mini.cursorword-expand}

- Current word under cursor now can be highlighted differently.

## mini.doc {#v0.3.0-mini.doc}

### Expand {#v0.3.0-mini.doc-expand}

- Introduction of a new module.

## mini.indentscope {#v0.3.0-mini.indentscope}

### Expand {#v0.3.0-mini.indentscope-expand}

- Introduction of a new module.

## mini.starter {#v0.3.0-mini.starter}

### Expand {#v0.3.0-mini.starter-expand}

- Implement `MiniStarter.set_query()` and make `<Esc>` mapping for resetting query.


# Version 0.2.0 {#v0.2.0}

## mini.base16 {#v0.2.0-mini.base16}

### Expand {#v0.2.0-mini.base16-expand}

- Use new `Diagnostic*` highlight groups in Neovim 0.6.0.

## mini.comment {#v0.2.0-mini.comment}

### Expand {#v0.2.0-mini.comment-expand}

- Respect tab indentation (#20).

## mini.jump {#v0.2.0-mini.jump}

### Expand {#v0.2.0-mini.jump-expand}

- Introduction of a new module.

## mini.pairs {#v0.2.0-mini.pairs}

### Expand {#v0.2.0-mini.pairs-expand}

- Implement pair registration with custom mapping functions:
    - Implement `MiniPairs.map()`, `MiniPairs.map_buf()`, `MiniPairs.unmap()`, `MiniPairs.unmap_buf()` to (un)make mappings for pairs which automatically register them for `<BS>` and `<CR>`. Note, that this has a minor break of previous behavior: now `MiniPairs.bs()` and `MiniPairs.cr()` don't have any input argument. But default behavior didn't change.
    - Allow setting global pair mappings inside `config` of `MiniPairs.setup()`.

## mini.sessions {#v0.2.0-mini.sessions}

### Expand {#v0.2.0-mini.sessions-expand}

- Introduction of a new module.

## mini.starter {#v0.2.0-mini.starter}

### Expand {#v0.2.0-mini.starter-expand}

- Introduction of a new module.

## mini.statusline {#v0.2.0-mini.statusline}

### Expand {#v0.2.0-mini.statusline-expand}

- Implement new section `MiniStatusline.section_searchcount()`.

- Update `section_diagnostics` to use `vim.diagnostic` in Neovim 0.6.0.


# Version 0.1.0 {#v0.1.0}

## All {#v0.1.0-all}

### Expand {#v0.1.0-all-expand}

- Initial stable version.
