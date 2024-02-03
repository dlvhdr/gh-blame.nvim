local utils = require("gh-blame.utils")
local time_ago = require("gh-blame.time-ago")
local Job = require("plenary.job")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
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
    buf_options = { filetype = "markdown" },
    enter = true,
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

  local title = NuiText(pr.title, "Title")
  local number = NuiText(" #" .. pr.number .. " ", "Conceal")
  local header = NuiLine({ title, number })
  header:render(popup.bufnr, -1, 1)

  local author = NuiText("@" .. pr.author.login, "ModeMsg")
  local mergedAt = NuiText("", "Normal")
  if pr.mergedAt ~= vim.NIL then
    local mergedAtUnixTime = utils.parse_json_date(pr.mergedAt)
    mergedAt = NuiText(" merged " .. time_ago.format(mergedAtUnixTime), "Normal")
  end
  local subtitle = NuiLine({ author, mergedAt })
  subtitle:render(popup.bufnr, -1, 2)

  local seperator = NuiText(" · ", "Conceal")
  local conversation = NuiText("Comments " .. pr.totalCommentsCount, "Conceal")
  local commits = NuiText("Commits " .. pr.commits.totalCount, "Conceal")
  local files = NuiText("Files " .. pr.changedFiles, "Conceal")
  local additions = NuiText("+" .. pr.additions, "diffAdded")
  local deletions = NuiText(" -" .. pr.deletions, "diffRemoved")
  local details = NuiLine({ conversation, seperator, commits, seperator, files, seperator, additions, deletions })
  details:render(popup.bufnr, -1, 3)

  local url = NuiLine({ NuiText("  → ", "Conceal"), NuiText(pr.url, "markdownLinkText") })
  url:render(popup.bufnr, -1, 4)
  NuiLine():render(popup.bufnr, -1, 5)

  local lineId = 6
  for _, line in ipairs(vim.split(pr.body, "\r\n")) do
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
          body
          number
          url
          mergedAt
          additions
          deletions
          totalCommentsCount
          commits {
            totalCount
          }
          changedFiles
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
