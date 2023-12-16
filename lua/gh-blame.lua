local gh = require("gh-blame.gh")
local utils = require("gh-blame.utils")
local git = require("gh-blame.git")

---@class Config
local config = {}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args Config?
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

M.show_current_line = function()
  GITHUB_TOKEN = vim.env["GITHUB_TOKEN"]

  local winid = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local lnum = utils.get_lnum(winid)
  local file = utils.get_buf_path(bufnr)

  local blame_sha = git.get_line_blame_sha(file, lnum)

  local repo_name_with_owner = gh.get_repo_name_with_owner()

  local pr = gh.find_associated_pr(repo_name_with_owner, blame_sha)
  gh.open_pr_popup(pr)
end

return M
