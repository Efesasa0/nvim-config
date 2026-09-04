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
vim.opt.fillchars:append({ eob = " " })
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

vim.keymap.set("n", "<leader>|", ":vsplit<CR>", { desc = "Vertical split (current window)" })
vim.keymap.set("n", "<leader>-", ":split<CR>", { desc = "Horizontal split (current window)" })
-- Full-span edge splits: new empty buffer spanning the whole editor edge
vim.keymap.set("n", "<leader>H", ":topleft vnew<CR>", { desc = "New buffer on far left (full height)" })
vim.keymap.set("n", "<leader>L", ":botright vnew<CR>", { desc = "New buffer on far right (full height)" })
vim.keymap.set("n", "<leader>K", ":topleft new<CR>", { desc = "New buffer on top (full width)" })
vim.keymap.set("n", "<leader>J", ":botright new<CR>", { desc = "New buffer on bottom (full width)" })

-- Window resizes
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Window swap: pick current window, navigate with <C-hjkl>, <CR> to swap buffers
vim.keymap.set("n", "<leader>ws", function()
	local source = vim.api.nvim_get_current_win()
	local source_buf = vim.api.nvim_win_get_buf(source)
	local saved = {}
	local function paint(win, hl)
		if not saved[win] and vim.api.nvim_win_is_valid(win) then
			saved[win] = vim.wo[win].winhighlight
		end
		if vim.api.nvim_win_is_valid(win) then
			vim.wo[win].winhighlight = hl
		end
	end
	local function unpaint(win)
		if saved[win] and vim.api.nvim_win_is_valid(win) then
			vim.wo[win].winhighlight = saved[win]
		end
		saved[win] = nil
	end
	local function cleanup()
		for win, _ in pairs(saved) do
			unpaint(win)
		end
	end
	paint(source, "Normal:DiffAdd,NormalNC:DiffAdd") -- source = green
	local cursor_win = source
	local function repaint_cursor()
		local w = vim.api.nvim_get_current_win()
		if w == cursor_win then return end
		if cursor_win ~= source then unpaint(cursor_win) end
		cursor_win = w
		if w ~= source then
			paint(w, "Normal:DiffChange,NormalNC:DiffChange") -- target-hover = orange
		end
	end
	local nav = {
		[vim.keycode("<C-h>")] = "h",
		[vim.keycode("<C-j>")] = "j",
		[vim.keycode("<C-k>")] = "k",
		[vim.keycode("<C-l>")] = "l",
		h = "h", j = "j", k = "k", l = "l",
	}
	while true do
		vim.cmd("redraw!")
		vim.api.nvim_echo(
			{ { "Swap: <C-hjkl> move (source=green, target=orange), <CR> swap, <Esc> cancel", "MoreMsg" } },
			false,
			{}
		)
		local ok, ch = pcall(vim.fn.getcharstr)
		if not ok or ch == "\27" then
			cleanup()
			vim.api.nvim_echo({ { "Swap cancelled", "WarningMsg" } }, false, {})
			return
		elseif ch == "\r" then
			local target = vim.api.nvim_get_current_win()
			cleanup()
			if target == source then
				vim.api.nvim_echo({ { "Same window - nothing to swap", "WarningMsg" } }, false, {})
				return
			end
			local target_buf = vim.api.nvim_win_get_buf(target)
			vim.api.nvim_win_set_buf(source, target_buf)
			vim.api.nvim_win_set_buf(target, source_buf)
			vim.api.nvim_echo({ { "Swapped", "MoreMsg" } }, false, {})
			return
		elseif nav[ch] then
			vim.cmd("wincmd " .. nav[ch])
			repaint_cursor()
		end
	end
end, { desc = "Enter window swap mode" })

-- Sessions (per-directory, saved to .nvim-session.vim)
vim.keymap.set("n", "<leader>ss", function()
	vim.cmd("mksession! .nvim-session.vim")
	vim.notify("Session saved: " .. vim.fn.getcwd() .. "/.nvim-session.vim")
end, { desc = "Save session for cwd" })
vim.keymap.set("n", "<leader>sr", function()
	if vim.fn.filereadable(".nvim-session.vim") == 1 then
		vim.cmd("source .nvim-session.vim")
	else
		vim.notify("No .nvim-session.vim in " .. vim.fn.getcwd(), vim.log.levels.WARN)
	end
end, { desc = "Restore session for cwd" })

-- LaTeX
vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<cr>", { desc = "Toggle LaTeX live compile (Skim)" })
vim.keymap.set("n", "<leader>lr", function()
	require("grammar_mode").toggle()
end, { desc = "Toggle grammar review mode (ltex-ls)" })

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

-- Equalize remaining splits after one closes
vim.api.nvim_create_autocmd("WinClosed", {
	group = augroup,
	callback = function()
		vim.schedule(function()
			vim.cmd("wincmd =")
		end)
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

-- Persistent terminal in current window (toggle to alt buffer)
local win_terminal = { buf = nil }

local function WinTerminal()
	local cur_win = vim.api.nvim_get_current_win()
	local cur_buf = vim.api.nvim_win_get_buf(cur_win)
	if win_terminal.buf and cur_buf == win_terminal.buf then
		vim.cmd("buffer #")
		return
	end
	if win_terminal.buf and vim.api.nvim_buf_is_valid(win_terminal.buf) then
		vim.api.nvim_win_set_buf(cur_win, win_terminal.buf)
	else
		vim.cmd("enew")
		vim.fn.termopen(os.getenv("SHELL"))
		win_terminal.buf = vim.api.nvim_get_current_buf()
	end
	vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>t", WinTerminal, { desc = "Toggle terminal in current window" })
vim.keymap.set("t", "<leader>t", function()
	vim.cmd("stopinsert")
	WinTerminal()
end, { desc = "Toggle terminal in current window (from term mode)" })

-- Terminal-mode window navigation (mirrors normal-mode <C-hjkl>)
for _, dir in ipairs({ "h", "j", "k", "l" }) do
	vim.keymap.set("t", "<C-" .. dir .. ">", "<C-\\><C-n><C-w>" .. dir, {
		desc = "Terminal mode: move to " .. dir .. " window",
	})
end

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
