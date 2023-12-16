> [!CAUTION]
> ROUGH DRAFT - super early in development

# gh-blame.nvim

![image](https://github.com/dlvhdr/gh-blame.nvim/assets/6196971/b700f784-7436-4895-a7b8-4da5571958e5)

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
