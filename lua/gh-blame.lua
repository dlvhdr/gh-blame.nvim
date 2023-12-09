-- main module file
local module = require("gh-blame.module")
local Job = require("plenary.job")
local gh = require("gh-blame.gh")

---@class Config
---@field opt string Your config option
local config = {
  opt = "Hello!",
}

---@class MyModule
local M = {}

---@type Config
M.config = config

---@param args Config?
-- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- you can also put some validation here for those.
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

local function get_lnum(winid)
  return vim.api.nvim_win_get_cursor(winid)[1]
end

local findAssociatedPullRequests = function(sha)
  local query = [[
query {
  resource(url: "https://github.com/dlvhdr/dotfiles/commit/]] .. sha .. [[") {
    ... on Commit {
      id
      associatedPullRequests(first: 1, orderBy: {field: CREATED_AT, direction:DESC}) {
        nodes {
          author {
            login
          }
          title
          number
          url
        }
      }
    }
  }
}
]]

  local res = gh.run({
    args = { "api", "graphql", "-f", "query=" .. query },
    mode = "sync",
  })
  vim.print(res)
end

M.hello = function()
  GITHUB_TOKEN = vim.env["GITHUB_TOKEN"]

  -- use gh api to do a git blame

  -- associatedPullRequests(
  --   after: String
  --   before: String
  --   first: Int
  --   last: Int
  --   orderBy: PullRequestOrder = {field: CREATED_AT, direction: ASC}
  -- ): PullRequestConnection

  local winid = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local lnum = get_lnum(winid)

  local file = vim.loop.fs_realpath(vim.api.nvim_buf_get_name(bufnr))
    or vim.api.nvim_buf_call(bufnr, function()
      return vim.fn.expand("%:p")
    end)

  vim.print({ winid, bufnr, lnum, file })
  local cmd = "git blame " .. file .. " -L " .. lnum .. ",+1 --incremental"
  vim.print("running: " .. cmd)

  local job = vim.fn.jobstart(cmd, {
    cwd = vim.fn.expand("%:p:h"),
    on_stdout = function(jobid, data, event)
      local lines = data
      if #lines < 1 then
        return
      end
      local sha = vim.split(lines[1], " ")[1]
      vim.print("FOUND SHA: " .. sha)

      findAssociatedPullRequests(sha)
    end,
    on_stderr = function(jobid, data, event)
      -- if #data == 0 then
      --   return
      -- end
      -- vim.print("error", jobid, data, event)
    end,
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(_, code)
      vim.print("exit code: " .. code)
    end,
  })
  vim.fn.jobwait({ job })
end

return M
