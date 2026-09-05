local M = {}

-- Session-scoped cache: fast re-renders within one nvim session, wiped on exit
local cache_dir = "/tmp/nvim-math-" .. vim.fn.getpid()
local buf_images = {} -- bufnr -> { image, image, ... }
local buf_enabled = {} -- bufnr -> true

local function ensure_cache()
	vim.fn.mkdir(cache_dir, "p")
end

local function safe_wipe_cache()
	-- guard: only ever touch a path that matches our exact naming pattern
	if not cache_dir:match("^/tmp/nvim%-math%-%d+$") then
		return
	end
	if vim.fn.isdirectory(cache_dir) == 0 then
		return
	end
	for _, f in ipairs(vim.fn.glob(cache_dir .. "/*.png", false, true)) do
		pcall(vim.fn.delete, f)
	end
	pcall(vim.uv.fs_rmdir, cache_dir)
end

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = safe_wipe_cache,
})

local function get_fg_color()
	if vim.g.math_render_fg then
		return vim.g.math_render_fg
	end
	if vim.o.termguicolors then
		local hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
		if hl and hl.fg then
			local r = bit.rshift(bit.band(hl.fg, 0xFF0000), 16) / 255
			local g = bit.rshift(bit.band(hl.fg, 0x00FF00), 8) / 255
			local b = bit.band(hl.fg, 0x0000FF) / 255
			return string.format("rgb %.3f %.3f %.3f", r, g, b)
		end
	end
	return "White"
end

local function compile(content)
	ensure_cache()
	local fg = get_fg_color()
	local hash = vim.fn.sha256(content .. "|" .. fg)
	local png = cache_dir .. "/" .. hash .. ".png"
	if vim.fn.filereadable(png) == 1 then
		return png
	end
	local tmp = vim.fn.tempname()
	local tex_body = string.format(
		"\\documentclass[preview,border=2pt]{standalone}\n"
			.. "\\usepackage{amsmath,amssymb,amsfonts}\n"
			.. "\\begin{document}\n"
			.. "\\[%s\\]\n"
			.. "\\end{document}\n",
		content
	)
	local tex_file = tmp .. ".tex"
	local dvi_file = tmp .. ".dvi"
	vim.fn.writefile(vim.split(tex_body, "\n"), tex_file)
	local dir = vim.fn.fnamemodify(tmp, ":h")
	local base = vim.fn.fnamemodify(tmp, ":t")
	local latex_ok = os.execute(
		string.format(
			"cd %s && latex -halt-on-error -interaction=nonstopmode %s.tex > /dev/null 2>&1",
			vim.fn.shellescape(dir),
			vim.fn.shellescape(base)
		)
	)
	if latex_ok ~= 0 and latex_ok ~= true then
		return nil
	end
	local dvi_ok = os.execute(
		string.format(
			"dvipng -D 200 -T tight -bg Transparent -fg %s -o %s %s > /dev/null 2>&1",
			vim.fn.shellescape(fg),
			vim.fn.shellescape(png),
			vim.fn.shellescape(dvi_file)
		)
	)
	if dvi_ok ~= 0 and dvi_ok ~= true then
		return nil
	end
	return png
end

local DELIMS = {
	{ open_pat = "^%s*%$%$%s*$", one_pat = "^%s*%$%$%s*(.-)%s*%$%$%s*$", rest_pat = "^%s*%$%$%s*(.+)$", close_pat = "^(.-)%s*%$%$%s*$" },
	{ open_pat = "^%s*\\%[%s*$", one_pat = "^%s*\\%[%s*(.-)%s*\\%]%s*$", rest_pat = "^%s*\\%[%s*(.+)$", close_pat = "^(.-)%s*\\%]%s*$" },
}

local function find_blocks(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local blocks = {}
	local in_block = false
	local start_line, content, close_pat = nil, {}, nil
	for i, line in ipairs(lines) do
		if not in_block then
			local matched = false
			for _, d in ipairs(DELIMS) do
				local one = line:match(d.one_pat)
				if one and one ~= "" then
					table.insert(blocks, { start = i - 1, content = one })
					matched = true
					break
				end
				if line:match(d.open_pat) then
					in_block = true
					start_line = i - 1
					content = {}
					close_pat = d.close_pat
					matched = true
					break
				end
				local rest = line:match(d.rest_pat)
				if rest then
					in_block = true
					start_line = i - 1
					content = { rest }
					close_pat = d.close_pat
					matched = true
					break
				end
			end
			if not matched then
				-- pass through
			end
		else
			local closing = line:match(close_pat)
			if closing then
				if closing ~= "" then
					table.insert(content, closing)
				end
				table.insert(blocks, { start = start_line, content = table.concat(content, " ") })
				in_block = false
				close_pat = nil
			else
				table.insert(content, line)
			end
		end
	end
	return blocks
end

function M.clear(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	for _, img in ipairs(buf_images[bufnr] or {}) do
		pcall(function() img:clear() end)
	end
	buf_images[bufnr] = nil
end

function M.render(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	M.clear(bufnr)
	local ok, image_api = pcall(require, "image")
	if not ok then
		vim.notify("image.nvim not available", vim.log.levels.WARN)
		return
	end
	local blocks = find_blocks(bufnr)
	if #blocks == 0 then
		vim.notify("math_render: no $$...$$ blocks found")
		return
	end
	local imgs = {}
	local failures = 0
	for _, b in ipairs(blocks) do
		local png = compile(b.content)
		if png then
			local img = image_api.from_file(png, {
				buffer = bufnr,
				window = vim.api.nvim_get_current_win(),
				inline = true,
				with_virtual_padding = true,
				x = 0,
				y = b.start,
			})
			if img then
				pcall(function() img:render() end)
				table.insert(imgs, img)
			end
		else
			failures = failures + 1
		end
	end
	buf_images[bufnr] = imgs
	local msg = string.format("math_render: %d block(s) rendered", #imgs)
	if failures > 0 then
		msg = msg .. string.format(", %d failed", failures)
	end
	vim.notify(msg)
end

function M.toggle(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if buf_enabled[bufnr] then
		M.clear(bufnr)
		buf_enabled[bufnr] = false
		vim.notify("math_render: off")
	else
		M.render(bufnr)
		buf_enabled[bufnr] = true
	end
end

function M.clean_cache()
	safe_wipe_cache()
	vim.notify("math_render: cache cleared")
end

function M.setup_autoupdate()
	vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
		pattern = { "*.md", "*.markdown" },
		callback = function(args)
			if buf_enabled[args.buf] then
				M.render(args.buf)
			end
		end,
	})
end

return M
