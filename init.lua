vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Display
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 30
vim.opt.smoothscroll = true
vim.opt.sidescrolloff = 8
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.showmode = false
vim.opt.termguicolors = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.laststatus = 3
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25"
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })
vim.opt.diffopt:append("linematch:60")
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.selection = "exclusive"
vim.opt.modifiable = true

-- Indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Search
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false

-- Files
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.autoread = true

-- Behaviour
vim.opt.errorbells = false
vim.opt.backspace = "indent,eol,start"
vim.opt.mouse = "a"
vim.opt.clipboard:append("unnamedplus")
vim.opt.encoding = "UTF-8"

-- Keymaps
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set("n", "<leader>a", "ggVG", { desc = "Select entire file" })
vim.keymap.set("n", "<leader><space>", function()
	local path = vim.fn.expand("%:.")
	local cwd = vim.fn.getcwd()
	vim.fn.setreg("+", path)
	vim.notify("path: " .. path .. "\ncwd:  " .. cwd, vim.log.levels.INFO)
end, { desc = "Show file path and cwd (copy path)" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result" })
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>k", function()
	local buf, win = vim.diagnostic.open_float(nil, {
		border = "rounded",
		scope = "line",
		max_width = 80,
		focusable = true,
	})
	if win then
		vim.api.nvim_set_current_win(win)
		vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, nowait = true })
	end
end, { desc = "Show diagnostic on line" })

vim.diagnostic.config({
	virtual_text = false,
	float = { border = "rounded" },
	severity_sort = true,
})

-- Arrow file bookmarks cycling
vim.keymap.set("n", "<C-o>", function()
	require("arrow.persist").next()
end, { desc = "Arrow next file" })
vim.keymap.set("n", "<C-i>", function()
	require("arrow.persist").previous()
end, { desc = "Arrow previous file" })

-- Window splits
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower buffer" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper buffer" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right buffer" })
vim.keymap.set("n", "<leader>z", "<:only<CR>", { desc = "Close window" })
vim.keymap.set("n", "<leader>x", "<cmd>close<cr>", { desc = "Close window" })

vim.keymap.set("n", "<leader>|", ":vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>-", ":split<CR>", { desc = "Horizontal split" })

-- Window resizes
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- LaTeX
vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<cr>", { desc = "Toggle LaTeX live compile (Skim)" })

-- Visual indentation
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent and reselect" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Dedent and reselect" })

-- Undo dir
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p")
end

-- Autocommands
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Return to last edit position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		local line = mark[1]
		local ft = vim.bo.filetype
		if
			line > 0
			and line <= lcount
			and vim.fn.index({ "commit", "gitrebase", "xxd" }, ft) == -1
			and not vim.o.diff
		then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- LaTeX auto-save on leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
	group = augroup,
	pattern = "*.tex",
	callback = function()
		if vim.bo.modified then
			vim.cmd("silent write")
		end
	end,
})

-- HTML live preview via live-server (toggle)
-- Override browser with: vim.g.html_preview_browser = "Google Chrome" (or "Firefox", "Arc", "Brave Browser", ...)
vim.g.html_preview_browser = vim.g.html_preview_browser or "Safari"
local live_server_job = nil
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "html",
	callback = function()
		vim.keymap.set("n", "<leader>ll", function()
			if live_server_job then
				vim.fn.jobstop(live_server_job)
				vim.fn.system({ "pkill", "-f", "live-server.*--port=5500" })
				live_server_job = nil
				vim.notify("Live rendering stopped")
				return
			end
			local dir = vim.fn.expand("%:p:h")
			local file = vim.fn.expand("%:t")
			local browser = vim.g.html_preview_browser
			live_server_job = vim.fn.jobstart({ "live-server", "--no-browser", "--port=5500", dir }, {
				detach = true,
				on_exit = function()
					live_server_job = nil
				end,
			})
			vim.defer_fn(function()
				vim.fn.jobstart({ "open", "-a", browser, "http://localhost:5500/" .. file }, { detach = true })
			end, 400)
			vim.notify("Live rendering " .. file .. " in " .. browser)
		end, { buffer = true, desc = "Toggle HTML live render in browser" })
	end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
	group = augroup,
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- Auto-reload files changed on disk
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	group = augroup,
	callback = function()
		if vim.api.nvim_get_mode().mode ~= "c" then
			vim.cmd("checktime")
		end
	end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
	group = augroup,
	callback = function()
		vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
	end,
})

local refresh_timer = vim.uv.new_timer()
refresh_timer:start(
	1000,
	1000,
	vim.schedule_wrap(function()
		if vim.api.nvim_get_mode().mode ~= "c" then
			pcall(vim.cmd, "checktime")
		end
	end)
)

-- Disable line numbers in terminal
vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})

-- Markdown text width and wrapping
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "markdown",
	callback = function()
		vim.opt_local.textwidth = 80
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
	end,
})

-- LaTeX text width and wrapping
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "tex",
	callback = function()
		vim.opt_local.textwidth = 80
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.colorcolumn = "80"
		vim.opt_local.formatoptions = vim.opt_local.formatoptions + "t"
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Floating terminal (bottom drawer)
local terminal_state = { buf = nil, win = nil, is_open = false }

local function FloatingTerminal()
	if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
		return
	end

	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		terminal_state.buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(terminal_state.buf, "bufhidden", "hide")
	end

	local width = vim.o.columns
	local height = math.floor(vim.o.lines * 0.4)
	local row = vim.o.lines - height - 2

	terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = 0,
		style = "minimal",
		border = "rounded",
	})

	vim.wo[terminal_state.win].number = false
	vim.wo[terminal_state.win].relativenumber = false
	vim.wo[terminal_state.win].signcolumn = "no"

	local lines = vim.api.nvim_buf_get_lines(terminal_state.buf, 0, -1, false)
	local has_terminal = false
	for _, line in ipairs(lines) do
		if line ~= "" then
			has_terminal = true
			break
		end
	end
	if not has_terminal then
		vim.fn.termopen(os.getenv("SHELL"))
	end

	terminal_state.is_open = true
	vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>t", FloatingTerminal, { desc = "Toggle floating terminal" })
vim.keymap.set("t", "<Esc>", function()
	if terminal_state.is_open then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
	end
end, { desc = "Close floating terminal" })

-- Plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
