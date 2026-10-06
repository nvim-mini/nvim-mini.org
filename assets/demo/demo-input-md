



- Get input from user:

```lua
-- The answer should be two
print(MiniInput.get({ prompt = 'What is one plus one?' }))
```

- `vim.ui.input` implementation:

```lua
-- Precise history which uses past inputs with same metadata
vim.ui.input({ prompt = 'Hello?', scope = 'cursor' }, print)
```

- Configurable view:

```lua
local view_uiline = MiniInput.gen_view.uiline()
MiniInput.get({ prompt = 'UI line', handlers = { view = view_uiline } })

local view_virtual = MiniInput.gen_view.virtual()
MiniInput.get({ prompt = 'Virtual', handlers = { view = view_virtual } })
```

- Integrates with other 'mini.nvim' modules.
