vim.api.nvim_create_user_command("MyFirstFunction", require("gh_blame").hello, {})
