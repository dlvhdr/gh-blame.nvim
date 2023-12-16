local utils = require("gh-blame.utils")
local Job = require("plenary.job")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local autocmd = require("nui.utils.autocmd")
local NuiLine = require("nui.line")
local NuiText = require("nui.text")

local M = {}

function M.run(opts)
  if not Job then
    return
  end
  opts = opts or {}
  local mode = opts.mode or "async"
  if opts.headers then
    for _, header in ipairs(opts.headers) do
      table.insert(opts.args, "-H")
      table.insert(opts.args, header)
    end
  end
  return utils.run_job("gh", opts, mode)
end

---@return string | nil
M.get_repo_name_with_owner = function()
  return M.run({
    args = { "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner" },
    mode = "sync",
  })
end

M.open_pr_popup = function(pr)
  local popup = Popup({
    focusable = true,
    border = {
      style = "rounded",
    },
    relative = "cursor",
    position = {
      col = 0,
      row = 0,
    },
    size = {
      width = "35%",
      height = 20,
    },
  })

  popup:map("n", "<esc>", function()
    popup:unmount()
  end, { noremap = true })
  popup:map("n", "q", function()
    popup:unmount()
  end, { noremap = true })

  popup:mount()

  popup:on(event.BufLeave, function()
    popup:unmount()
  end)

  local bufnr = vim.api.nvim_get_current_buf()
  autocmd.buf.define(bufnr, event.CursorMoved, function()
    popup:unmount()
  end, { once = true })

  local number = NuiText("#" .. pr.number .. " ", "Label")
  local title = NuiText(pr.title, "Title")
  local header = NuiLine({ number, title })
  header:render(popup.bufnr, -1, 1)

  local author = NuiLine({ NuiText(pr.author.login, "LineNr") })
  author:render(popup.bufnr, -1, 2)
  local url = NuiLine({ NuiText(pr.url, "Label") })
  url:render(popup.bufnr, -1, 3)

  vim.print(pr.bodyText)
  local lineId = 4
  for _, line in ipairs(vim.split(pr.bodyText, "\n")) do
    local description = NuiLine({ NuiText(line) })
    description:render(popup.bufnr, -1, lineId)
    lineId = lineId + 1
  end
end

M.find_associated_pr = function(repo, sha)
  local query = [[
query Blame($url: URI!) {
  resource(url: $url) {
    ... on Commit {
      id
      associatedPullRequests(first: 1, orderBy: {field: CREATED_AT, direction:DESC}) {
        nodes {
          author {
            login
          }
          title
          bodyText
          number
          url
        }
      }
    }
  }
}
]]

  local url = "https://github.com/" .. repo .. "/commit/" .. sha
  local res = M.run({
    args = { "api", "graphql", "-f", "query=" .. query, "-f", "url=" .. url },
    mode = "sync",
  })
  if res == nil then
    return nil
  end

  -- parse json results
  local json = vim.fn.json_decode(res)

  if
    json == nil
    or json.data == nil
    or json.data.resource == nil
    or json.data.resource.associatedPullRequests == nil
    or json.data.resource.associatedPullRequests.nodes == nil
    or #json.data.resource.associatedPullRequests.nodes < 1
  then
    return nil
  end

  return json.data.resource.associatedPullRequests.nodes[1]
end

return M
