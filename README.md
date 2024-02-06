> [!CAUTION]
> Early in development

# gh-blame.nvim

![image](https://github.com/dlvhdr/gh-blame.nvim/assets/6196971/ae9e41f2-4d26-46f2-9bfa-0d5ed7769f69)

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
- [ ] Blame on cursor hold
- [ ] Blame sidebar like in fugitive
