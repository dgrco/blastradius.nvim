# blastradius.nvim

BlastRadius is a Neovim plugin that lets you explore the **commit context of a single line**.

From any line in a Git-tracked file, you can jump to the commit that last modified 
it and inspect **all files changed in that commit** (the line’s *blast radius*).

This is useful for:
- understanding why a line exists
- reviewing related changes
- auditing historical context
- navigating large or unfamiliar codebases

---

## ✨ Features

- Get the Git commit that last modified the current line
- List all files changed in that commit
- View diffs for any file in the commit
- Handles:
  - initial commits
  - uncommitted lines
  - missing Git repositories
- Telescope integration with `vim.ui.select` fallback

## Installation

### lazy.nvim
```lua
{
  "dgrco/blastradius.nvim",
  config = function()
    require("blastradius").setup()
  end,
}
```

---

## 🚀 Usage

With the cursor on any line in a Git-tracked file:

`<leader>gb`
