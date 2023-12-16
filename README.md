# gh-blame.nvim

## Requirements

Install the `gh` CLI - see the [installation](https://github.com/cli/cli#installation)

## Usage

```lua
return {
  "dlvhdr/gh-blame.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
  keys = {
    { "<leader>gg", "<cmd>GhBlameCurrentLine<cr>", desc = "GitHub Blame Current Line" },
  },
}
```
