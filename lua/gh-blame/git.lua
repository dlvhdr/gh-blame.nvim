local utils = require("gh-blame.utils")

local M = {}

M.get_line_blame_sha = function(file, lnum)
  local blame_output = utils.run_job("git", {
    args = { "blame", file, "-L" .. lnum .. ",+1", "--incremental" },
    cwd = vim.fn.expand("%:p:h"),
  }, "sync")

  local lines = vim.split(blame_output, "\n")
  if #lines < 1 then
    return
  end
  return vim.split(lines[1], " ")[1]
end

return M
