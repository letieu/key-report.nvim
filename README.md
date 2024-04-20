# key-report.nvim

Statistics for keymaps in Neovim

> [!CAUTION]
> Currently, this plugin is under development. It may not work as expected.

## Features
- **Log keymaps usage**: Count how many times you use a keymap.
- **Report keymaps usage**: Show a report of keymaps usage.

## Installation

* With **lazy.nvim**

```lua
{
  "letieu/key-report.nvim",
  config = function()
    require('key-report').setup()
  end,
}
```

**Important**: don't forget to call `require('key-report').setup()` to enable its functionality.

## Configuration

```lua
-- TODO
require('btw').setup({})
```

## TODO
- [x] Log keymaps usage
- [ ] Show a report of keymaps usage (Sort by count, keymap, mode, etc.)
- [ ] Configuration
