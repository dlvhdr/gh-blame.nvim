# gh-blame.nvim

## Requirements

Install the `gh` CLI - see the [installation instructions](https://github.com/cli/cli#installation)

## Installation

Using lazy:
```lua
return {
  "dlvhdr/gh-blame.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
  keys = {
    { "<leader>gg", "<cmd>GhBlameCurrentLine<cr>", desc = "GitHub Blame Current Line" },
  },
}
```

## TODO

- [ ] Handle errors
- [ ] Prettify output with markdown parsing
- [ ] Blame on cursor hold
- [ ] Blame sidebar like in fugitive
