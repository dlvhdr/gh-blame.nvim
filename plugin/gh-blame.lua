vim.api.nvim_create_user_command("GhBlameCurrentLine", require("gh-blame").show_current_line, {})
