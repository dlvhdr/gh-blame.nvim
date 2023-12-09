local Job = require("plenary.job")

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
  vim.print("running", "gh", opts.args)
  local job = Job:new({
    enable_recording = true,
    command = "gh",
    args = opts.args,
    on_stdout = vim.schedule_wrap(function(err, data, _)
      if mode == "async" and opts.stream_cb then
        opts.stream_cb(data, err)
      end
    end),
    on_exit = vim.schedule_wrap(function(j_self, _, _)
      if mode == "async" and opts.cb then
        local output = table.concat(j_self:result(), "\n")
        local stderr = table.concat(j_self:stderr_result(), "\n")
        opts.cb(output, stderr)
      end
    end),
  })
  if mode == "sync" then
    job:sync()
    return table.concat(job:result(), "\n"), table.concat(job:stderr_result(), "\n")
  else
    job:start()
  end
end

return M
