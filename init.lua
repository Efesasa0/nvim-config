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
-- Portable across machines: absolute cwd is rewritten to a relative prefix on save,
-- so a mirrored tree at a different absolute root (e.g., mac vs EC2) restores fine.
vim.keymap.set("n", "<leader>ss", function()
	local cwd = vim.fn.getcwd()
	vim.cmd("mksession! .nvim-session.vim")
	local path = cwd .. "/.nvim-session.vim"
	local ok, lines = pcall(vim.fn.readfile, path)
	if ok then
		local escaped = vim.pesc(cwd)
		for i, line in ipairs(lines) do
			lines[i] = line:gsub(escaped, ".")
		end
		vim.fn.writefile(lines, path)
	end
	vim.notify("Session saved (portable): " .. path)
end, { desc = "Save session for cwd" })
vim.keymap.set("n", "<leader>sr", function()
	if vim.fn.filereadable(".nvim-session.vim") ~= 1 then
		vim.notify("No .nvim-session.vim in " .. vim.fn.getcwd(), vim.log.levels.WARN)
		return
	end
	local lines = vim.fn.readfile(".nvim-session.vim")
	-- auto-heal: find the session's cd target (either `~/foo` or absolute) and strip it
	local raw
	for _, line in ipairs(lines) do
		local m = line:match("^l?cd!?%s+(%S+)")
		if m then
			raw = m
			break
		end
	end
	local current = vim.fn.getcwd()
	local heal = false
	local prefixes = {}
	if raw then
		local expanded = vim.fn.expand(raw)
		if expanded ~= current then
			heal = true
			table.insert(prefixes, raw)
			if expanded ~= raw then
				table.insert(prefixes, expanded)
			end
		end
	end
	if heal then
		for i, line in ipairs(lines) do
			for _, p in ipairs(prefixes) do
				lines[i] = lines[i]:gsub(vim.pesc(p), ".")
			end
		end
		local tmp = vim.fn.tempname()
		vim.fn.writefile(lines, tmp)
		vim.cmd("source " .. vim.fn.fnameescape(tmp))
		vim.fn.delete(tmp)
	else
		vim.cmd("source .nvim-session.vim")
	end
end, { desc = "Restore session for cwd" })

-- Visual selection → freeze SVG (system font, no glyph embed) → svgo → pbcopy
vim.keymap.set("x", "<leader>ci", function()
	local save_reg = vim.fn.getreg("z")
	local save_type = vim.fn.getregtype("z")
	-- gv reselects the last visual range (keymap callback runs in normal mode),
	-- then "zy yanks it into register z
	vim.cmd('normal! gv"zy')
	local selection = vim.fn.getreg("z")
	vim.fn.setreg("z", save_reg, save_type)
	if selection == "" then
		vim.notify("Nothing selected", vim.log.levels.WARN)
		return
	end
	local _, nl_count = selection:gsub("\n", "\n")
	vim.notify(string.format("captured %d bytes across %d line(s)", #selection, nl_count + 1))
	local ft = vim.bo.filetype
	local lang = (ft ~= "" and ft) or "text"
	local raw = vim.fn.tempname() .. ".svg"
	local opt = vim.fn.tempname() .. ".svg"
	local freeze_cmd = string.format(
		"freeze --language %s --theme catppuccin-latte --font.family Menlo --output %s -",
		vim.fn.shellescape(lang),
		vim.fn.shellescape(raw)
	)
	local freeze_out = vim.fn.system(freeze_cmd, selection)
	if vim.v.shell_error ~= 0 then
		pcall(vim.fn.delete, raw)
		vim.notify("freeze failed: " .. freeze_out, vim.log.levels.ERROR)
		return
	end
	local svgo_out = vim.fn.system(string.format("svgo %s -o %s", vim.fn.shellescape(raw), vim.fn.shellescape(opt)))
	if vim.v.shell_error ~= 0 then
		-- fall back to raw freeze output if svgo bails
		opt = raw
	end
	local size = vim.fn.getfsize(opt)
	vim.fn.system("pbcopy < " .. vim.fn.shellescape(opt))
	pcall(vim.fn.delete, raw)
	if opt ~= raw then
		pcall(vim.fn.delete, opt)
	end
	vim.notify(string.format("SVG copied to clipboard (%s, %d bytes)", lang, size))
end, { desc = "Copy selection as SVG image to clipboard" })

-- LaTeX
vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<cr>", { desc = "Toggle LaTeX live compile (Skim)" })
vim.keymap.set("n", "<leader>lr", function()
	require("grammar_mode").toggle()
end, { desc = "Toggle grammar review mode (ltex-ls)" })
vim.keymap.set("n", "<leader>lm", function()
	require("math_render").toggle()
end, { desc = "Toggle inline math rendering (markdown)" })
vim.keymap.set("n", "<leader>fm", function()
	local conform = require("conform")
	local bufnr = vim.api.nvim_get_current_buf()
	local ft = vim.bo[bufnr].filetype
	local available = conform.list_formatters(bufnr)
	if #available == 0 then
		vim.notify("No formatter for filetype '" .. ft .. "'", vim.log.levels.WARN)
		return
	end
	local names = {}
	for _, f in ipairs(available) do
		table.insert(names, f.name .. (f.available and "" or " (missing)"))
	end
	conform.format({ bufnr = bufnr, timeout_ms = 3000, lsp_fallback = true }, function(err)
		if err then
			vim.notify("Format failed: " .. tostring(err), vim.log.levels.ERROR)
		else
			vim.notify("Formatted with: " .. table.concat(names, ", "))
		end
	end)
end, { desc = "Format current buffer (manual)" })
require("math_render").setup_autoupdate()

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

-- Welcome buffer when nvim starts with no args
vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup,
	callback = function()
		if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
			require("welcome").show()
		end
	end,
})

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

-- Manual equalize on demand (was auto on WinClosed, but that wiped resizes
-- whenever any floating picker opened/closed).
vim.keymap.set("n", "<leader>=", "<C-w>=", { desc = "Equalize window sizes" })

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
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
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

-- HTML text width and wrapping
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "html",
	callback = function()
		vim.opt_local.textwidth = 100
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

-- Floating terminal (bottom drawer, hovers over layout)
local terminal_state = { buf = nil, win = nil, is_open = false }

local function FloatingTerminal()
	if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
		return
	end

	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		terminal_state.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[terminal_state.buf].bufhidden = "hide"
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
	if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
	end
end, { desc = "Close floating terminal" })

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
