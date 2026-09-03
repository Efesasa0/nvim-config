local M = {}

local ns = vim.api.nvim_create_namespace("grammar_mode")

local state = {
	active = false,
	bufnr = nil,
	issues = {},
	index = 1,
	status_win = nil,
	status_buf = nil,
	popup_win = nil,
	popup_buf = nil,
	extmark_id = nil,
	current_actions = {},
	saved_keymaps = {},
}

local KEY_HINTS = {
	{ "a", "accept top suggestion" },
	{ "1/2/3", "pick suggestion N" },
	{ "s", "skip issue" },
	{ "d", "add word to dictionary" },
	{ "i", "ignore this rule (session)" },
	{ "n", "next issue" },
	{ "p", "previous issue" },
	{ "<Esc>", "quit grammar mode" },
}

local function classify(diag)
	local code = tostring(diag.code or ""):upper()
	local msg = (diag.message or ""):lower()
	if code:match("MORFOLOGIK") or msg:match("spelling") then
		return "typosC"
	end
	if code:match("WORDINESS") or code:match("REDUNDAN") or msg:match("wordy") or msg:match("shorter") then
		return "shortenC"
	end
	if code:match("PASSIVE") then
		return "passiveC"
	end
	if code:match("PUNCTUATION") or code:match("COMMA") then
		return "punctC"
	end
	return "otherC"
end

local function collect_diagnostics(bufnr)
	local all = vim.diagnostic.get(bufnr)
	local out = {}
	for _, d in ipairs(all) do
		if (d.source or ""):match("[Ll][Tt]e[Xx]") or (d.source or "") == "LanguageTool" then
			table.insert(out, d)
		end
	end
	table.sort(out, function(a, b)
		if a.lnum == b.lnum then
			return a.col < b.col
		end
		return a.lnum < b.lnum
	end)
	return out
end

local function close_win(win)
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
end

local function clear_extmark()
	if state.extmark_id then
		vim.api.nvim_buf_del_extmark(state.bufnr, ns, state.extmark_id)
		state.extmark_id = nil
	end
end

local function render_status()
	local counts = { typosC = 0, shortenC = 0, passiveC = 0, punctC = 0, otherC = 0 }
	for _, d in ipairs(state.issues) do
		local c = classify(d)
		counts[c] = (counts[c] or 0) + 1
	end
	local pieces = {}
	for _, k in ipairs({ "typosC", "shortenC", "passiveC", "punctC", "otherC" }) do
		if counts[k] > 0 then
			table.insert(pieces, k .. " " .. counts[k])
		end
	end
	local line =
		string.format("[%s]  %d/%d  <Esc> quit", table.concat(pieces, " | "), state.index, #state.issues)

	if not state.status_win or not vim.api.nvim_win_is_valid(state.status_win) then
		state.status_buf = vim.api.nvim_create_buf(false, true)
		local w = math.min(vim.o.columns - 2, #line + 2)
		state.status_win = vim.api.nvim_open_win(state.status_buf, false, {
			relative = "editor",
			anchor = "SE",
			row = vim.o.lines - 2,
			col = vim.o.columns,
			width = w,
			height = 1,
			style = "minimal",
			border = "single",
			focusable = false,
			zindex = 60,
		})
	end
	vim.api.nvim_buf_set_lines(state.status_buf, 0, -1, false, { line })
end

local function request_code_actions(diag, cb)
	local params = {
		textDocument = vim.lsp.util.make_text_document_params(state.bufnr),
		range = {
			start = { line = diag.lnum, character = diag.col },
			["end"] = { line = diag.end_lnum or diag.lnum, character = diag.end_col or diag.col },
		},
		context = { diagnostics = { diag }, only = { "quickfix" } },
	}
	vim.lsp.buf_request_all(state.bufnr, "textDocument/codeAction", params, function(results)
		local actions = {}
		for _, r in pairs(results or {}) do
			for _, a in ipairs(r.result or {}) do
				table.insert(actions, a)
			end
		end
		cb(actions)
	end)
end

local function show_popup(diag, actions)
	close_win(state.popup_win)
	state.popup_buf = vim.api.nvim_create_buf(false, true)

	local category = classify(diag)
	local lines = {
		string.format("Issue %d/%d  [%s]  rule: %s", state.index, #state.issues, category, tostring(diag.code or "?")),
		"",
		"» " .. (diag.message or ""),
		"",
		"Suggestions:",
	}

	local suggestion_actions = {}
	for _, a in ipairs(actions) do
		local title = a.title or ""
		if not title:lower():match("dictionary") and not title:lower():match("disable") and not title:lower():match("hide false") then
			table.insert(suggestion_actions, a)
		end
	end
	state.current_actions = { suggestions = suggestion_actions, all = actions }

	if #suggestion_actions == 0 then
		table.insert(lines, "  (none - use s to skip or i to ignore rule)")
	else
		for i, a in ipairs(suggestion_actions) do
			if i > 9 then break end
			table.insert(lines, string.format("  %d  %s", i, a.title))
		end
	end

	table.insert(lines, "")
	table.insert(lines, "Keys:")
	for _, k in ipairs(KEY_HINTS) do
		table.insert(lines, string.format("  %-8s %s", k[1], k[2]))
	end

	local width = 0
	for _, l in ipairs(lines) do
		if #l > width then width = #l end
	end
	width = math.min(width + 2, vim.o.columns - 4)

	vim.api.nvim_buf_set_lines(state.popup_buf, 0, -1, false, lines)
	state.popup_win = vim.api.nvim_open_win(state.popup_buf, false, {
		relative = "cursor",
		anchor = "NW",
		row = 1,
		col = 0,
		width = width,
		height = #lines,
		style = "minimal",
		border = "rounded",
		focusable = false,
		zindex = 55,
	})
end

local function jump_and_highlight(diag)
	clear_extmark()
	pcall(vim.api.nvim_win_set_cursor, 0, { diag.lnum + 1, diag.col })
	state.extmark_id = vim.api.nvim_buf_set_extmark(state.bufnr, ns, diag.lnum, diag.col, {
		end_row = diag.end_lnum or diag.lnum,
		end_col = diag.end_col or diag.col,
		hl_group = "IncSearch",
	})
end

local show_current -- forward decl

local function apply_action(action)
	if not action then return end
	local client = vim.lsp.get_clients({ bufnr = state.bufnr, name = "ltex_plus" })[1]
		or vim.lsp.get_clients({ bufnr = state.bufnr, name = "ltex" })[1]
	if action.edit then
		vim.lsp.util.apply_workspace_edit(action.edit, (client and client.offset_encoding) or "utf-16")
	end
	if action.command then
		local cmd = type(action.command) == "table" and action.command or { command = action.command }
		local local_handler = vim.lsp.commands and vim.lsp.commands[cmd.command]
		if local_handler then
			local_handler(cmd, { bufnr = state.bufnr, client_id = client and client.id })
		elseif client then
			pcall(function() client:exec_cmd(cmd, { bufnr = state.bufnr }) end)
		end
	end
end

show_current = function()
	if #state.issues == 0 or state.index > #state.issues then
		close_win(state.popup_win)
		clear_extmark()
		render_status()
		vim.notify("Grammar mode: no more issues")
		M.stop()
		return
	end
	if state.index < 1 then state.index = 1 end
	local diag = state.issues[state.index]
	jump_and_highlight(diag)
	render_status()
	request_code_actions(diag, function(actions)
		vim.schedule(function() show_popup(diag, actions) end)
	end)
end

local function resolve_current_and_advance()
	table.remove(state.issues, state.index)
	-- keep the same index; it now naturally points to what was the next issue
	vim.defer_fn(show_current, 50)
end

local function next_issue()
	if state.index < #state.issues then
		state.index = state.index + 1
		show_current()
	end
end

local function prev_issue()
	if state.index > 1 then
		state.index = state.index - 1
		show_current()
	end
end

local function accept(n)
	local s = state.current_actions.suggestions or {}
	local action = s[n or 1]
	if not action then
		vim.notify("No suggestion at slot " .. (n or 1))
		return
	end
	apply_action(action)
	resolve_current_and_advance()
end

local function skip()
	if state.index < #state.issues then
		state.index = state.index + 1
		show_current()
	else
		vim.notify("Grammar mode: last issue - skip has no next")
	end
end

local function add_to_dictionary()
	local all = state.current_actions.all or {}
	for _, a in ipairs(all) do
		if (a.title or ""):lower():match("dictionary") or (a.title or ""):lower():match("add.*word") then
			apply_action(a)
			resolve_current_and_advance()
			return
		end
	end
	vim.notify("No 'add to dictionary' action offered by server")
end

local function ignore_rule()
	local all = state.current_actions.all or {}
	for _, a in ipairs(all) do
		if (a.title or ""):lower():match("disable rule") or (a.title or ""):lower():match("hide false") then
			apply_action(a)
			resolve_current_and_advance()
			return
		end
	end
	vim.notify("No 'disable rule' action offered by server")
end

local MODE_KEYS = {
	["a"] = accept,
	["1"] = function() accept(1) end,
	["2"] = function() accept(2) end,
	["3"] = function() accept(3) end,
	["4"] = function() accept(4) end,
	["5"] = function() accept(5) end,
	["s"] = skip,
	["d"] = add_to_dictionary,
	["i"] = ignore_rule,
	["n"] = next_issue,
	["p"] = prev_issue,
}

local function bind_keys()
	for key, fn in pairs(MODE_KEYS) do
		vim.keymap.set("n", key, fn, { buffer = state.bufnr, desc = "Grammar mode: " .. key })
	end
	vim.keymap.set("n", "<Esc>", function() M.stop() end, { buffer = state.bufnr, desc = "Grammar mode: quit" })
end

local function unbind_keys()
	for key, _ in pairs(MODE_KEYS) do
		pcall(vim.keymap.del, "n", key, { buffer = state.bufnr })
	end
	pcall(vim.keymap.del, "n", "<Esc>", { buffer = state.bufnr })
end

function M.start()
	if state.active then return end
	local bufnr = vim.api.nvim_get_current_buf()
	local ltex_up = #vim.lsp.get_clients({ bufnr = bufnr, name = "ltex_plus" }) > 0
		or #vim.lsp.get_clients({ bufnr = bufnr, name = "ltex" }) > 0
	if not ltex_up then
		vim.notify("ltex-ls not attached to this buffer yet. Wait a moment or check :LspInfo.", vim.log.levels.WARN)
		return
	end
	state.active = true
	state.bufnr = bufnr
	state.index = 1
	state.issues = collect_diagnostics(bufnr)
	if #state.issues == 0 then
		vim.notify("Grammar mode: no LTeX issues in this buffer")
		state.active = false
		return
	end
	bind_keys()
	show_current()
end

function M.stop()
	if not state.active then return end
	unbind_keys()
	close_win(state.popup_win)
	close_win(state.status_win)
	clear_extmark()
	state.active = false
	state.issues = {}
	state.current_actions = {}
	vim.notify("Grammar mode: exited")
end

function M.toggle()
	if state.active then M.stop() else M.start() end
end

return M
