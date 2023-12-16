local Job = require("plenary.job")

local M = {}

M.get_lnum = function(winid)
  return vim.api.nvim_win_get_cursor(winid)[1]
end

M.get_buf_path = function(bufnr)
  return vim.loop.fs_realpath(vim.api.nvim_buf_get_name(bufnr))
    or vim.api.nvim_buf_call(bufnr, function()
      return vim.fn.expand("%:p")
    end)
end

M.run_job = function(command, opts, mode)
  local job = Job:new({
    command = command,
    cwd = opts.cwd,
    args = opts.args,
    enable_recording = true,
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
