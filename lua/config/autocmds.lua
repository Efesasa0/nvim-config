-- Autocommands configuration

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    local line = mark[1]
    local ft = vim.bo.filetype
    if line > 0 and line <= lcount
      and vim.fn.index({ "commit", "gitrebase", "xxd" }, ft) == -1
      and not vim.o.diff then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Disable line numbers in terminal
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- LaTeX auto-save on InsertLeave
vim.api.nvim_create_autocmd("InsertLeave", {
  group = augroup,
  pattern = "*.tex",
  callback = function()
    if vim.bo.modified then
      vim.cmd("silent write")
    end
  end,
})

-- Auto-reload files when changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = augroup,
  callback = function()
    if vim.api.nvim_get_mode().mode ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Notify when file changes
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = augroup,
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
})

-- Timer-based auto-refresh (checks every 1 second even without focus)
local refresh_timer = vim.uv.new_timer()
refresh_timer:start(1000, 1000, vim.schedule_wrap(function()
  if vim.api.nvim_get_mode().mode ~= "c" then
    pcall(vim.cmd, "checktime")
  end
end))

-- Jupyter Notebook support: convert .ipynb to .py on open, sync back on save
local notebook_group = vim.api.nvim_create_augroup("JupyterNotebook", { clear = true })

vim.api.nvim_create_autocmd("BufReadCmd", {
  group = notebook_group,
  pattern = "*.ipynb",
  callback = function(args)
    local ipynb_path = args.file
    local py_path = ipynb_path:gsub("%.ipynb$", ".py")

    -- Check if file exists and is not empty
    local stat = vim.uv.fs_stat(ipynb_path)
    if not stat or stat.size == 0 then
      -- Create a new empty notebook
      local empty_nb = '{"cells": [], "metadata": {"kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"}}, "nbformat": 4, "nbformat_minor": 5}'
      local f = io.open(ipynb_path, "w")
      if f then
        f:write(empty_nb)
        f:close()
      end
    end

    -- Convert notebook to python script
    local result = vim.fn.system({ "jupytext", "--to", "py:percent", ipynb_path, "-o", py_path })
    if vim.v.shell_error ~= 0 then
      vim.notify("jupytext conversion failed: " .. result, vim.log.levels.ERROR)
      return
    end

    -- Open the python file instead
    vim.cmd("edit " .. vim.fn.fnameescape(py_path))
    vim.notify("Opened as Python (jupytext). Save syncs back to .ipynb", vim.log.levels.INFO)
  end,
})

-- Sync .py back to .ipynb on save (for files that have a matching notebook)
vim.api.nvim_create_autocmd("BufWritePost", {
  group = notebook_group,
  pattern = "*.py",
  callback = function(args)
    local py_path = args.file
    local ipynb_path = py_path:gsub("%.py$", ".ipynb")

    -- Only sync if the notebook exists
    if vim.fn.filereadable(ipynb_path) == 1 then
      vim.fn.system({ "jupytext", "--sync", py_path })
      vim.notify("Synced to " .. vim.fn.fnamemodify(ipynb_path, ":t"), vim.log.levels.INFO)
    end
  end,
})

-- PDF: render as plain text via pdftotext (requires: brew install poppler)
local pdf_group = vim.api.nvim_create_augroup("PDFReader", { clear = true })

vim.api.nvim_create_autocmd("BufReadCmd", {
  group = pdf_group,
  pattern = "*.pdf",
  callback = function(args)
    local path = vim.fn.fnamemodify(args.file, ":p")
    local text = vim.fn.system({ "pdftotext", "-layout", "-nopgbrk", path, "-" })
    if vim.v.shell_error ~= 0 then
      vim.notify("pdftotext failed — is poppler installed? (brew install poppler)", vim.log.levels.ERROR)
      return
    end
    text = text:gsub("\f", "\n")  -- strip form-feed page breaks
    local lines = vim.split(text, "\n")
    local has_text = text:match("%S") ~= nil
    if not has_text then
      lines = { "[ This PDF has no extractable text — it is likely a scanned image. ]", "", "[ Use a PDF viewer like Skim or Preview to read it. ]" }
      vim.notify("Scanned image PDF — no text layer found.", vim.log.levels.WARN)
    end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.bo.filetype = "text"
    vim.bo.modifiable = false
    vim.bo.modified = false
  end,
})

-- Markdown text width constraint
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "markdown",
  callback = function()
    vim.opt_local.textwidth = 80
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})


